using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using TerraON.Domain.Entities;
using TerraON.Domain.Repositories.Reports;

namespace TerraON.Infrastructure.Pdf
{
    public class ReportPdfExporter : IReportPdfExporter
    {
        public byte[] Generate(IEnumerable<Report> reports, string? title = null)
        {
            QuestPDF.Settings.License = LicenseType.Community;

            var reportList = reports?.ToList() ?? [];
            var now = DateTime.Now;

            using var stream = new MemoryStream();

            Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(30);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(11).FontFamily(Fonts.Arial));

                    page.Header().Column(col =>
                    {
                        col.Item().Text(title ?? "Relatório de Denúncias - TerraON")
                            .FontSize(18)
                            .SemiBold();

                        col.Item().Text($"Gerado em: {now:dd/MM/yyyy HH:mm}")
                            .FontSize(9)
                            .FontColor(Colors.Grey.Darken2);
                    });

                    page.Content().PaddingTop(10).Column(col =>
                    {
                        foreach (var report in reportList)
                        {
                            col.Item().Element(c => BuildReportBlock(c, report));
                            col.Item().PageBreak();
                        }
                    });

                    page.Footer().AlignRight().Text(text =>
                    {
                        text.Span("Página ").FontSize(9);
                        text.CurrentPageNumber().FontSize(9);
                        text.Span(" de ").FontSize(9);
                        text.TotalPages().FontSize(9);
                    });
                });
            })
            .GeneratePdf(stream);

            return stream.ToArray();
        }

        private static void BuildReportBlock(IContainer container, Report report)
        {
            container.Column(col =>
            {
                col.Spacing(6);

                // Cabeçalho da denúncia
                col.Item().Row(row =>
                {
                    row.RelativeItem().Column(c =>
                    {
                        c.Item().Text($"Denúncia #{report.Id}")
                            .FontSize(14)
                            .SemiBold();

                        c.Item().Text($"Autor: {report.Author?.Name ?? "-"}")
                            .FontSize(10);

                        if (!string.IsNullOrWhiteSpace(report.Author?.Email))
                        {
                            c.Item().Text($"E-mail: {report.Author.Email}")
                                .FontSize(10);
                        }

                        c.Item().Text($"Status: {GetStatusLabel(report.Status)}")
                            .FontSize(10);
                    });

                    row.ConstantItem(120).Column(c =>
                    {
                        c.Item().AlignRight().Text("Engajamento")
                            .FontSize(10)
                            .SemiBold();

                        c.Item().AlignRight().Text($"Curtidas: {report.Likes?.Count ?? 0}")
                            .FontSize(10);
                    });
                });

                // Endereço / localização
                col.Item().BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2);

                col.Item().Column(c =>
                {
                    c.Item()
                        .PaddingTop(4)
                        .Text("Localização")
                        .FontSize(11)
                        .SemiBold();

                    c.Item().Text(BuildAddress(report))
                        .FontSize(10);

                    if (!string.IsNullOrWhiteSpace(report.Latitude) &&
                        !string.IsNullOrWhiteSpace(report.Longitude))
                    {
                        c.Item().Text($"Coordenadas: {report.Latitude}, {report.Longitude}")
                            .FontSize(10);
                    }
                });

                // Descrição
                if (!string.IsNullOrWhiteSpace(report.Description))
                {
                    col.Item().PaddingTop(6).Column(c =>
                    {
                        c.Item().Text("Descrição")
                            .FontSize(11)
                            .SemiBold();

                        c.Item().Text(report.Description)
                            .FontSize(11);
                    });
                }

                // Imagens
                if (report.Images != null && report.Images.Any(i => i.Data is { Length: > 0 }))
                {
                    col.Item().PaddingTop(8).Column(c =>
                    {
                        c.Item().Text("Imagens")
                            .FontSize(11)
                            .SemiBold();

                        c.Item().Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn();
                                columns.RelativeColumn();
                            });

                            var imgs = report.Images.Where(i => i.Data is { Length: > 0 }).ToList();

                            for (int i = 0; i < imgs.Count; i += 2)
                            {
                                table.Cell().Element(cell =>
                                    BuildImageCell(cell, imgs[i].Data));

                                // Se houver imagem da segunda coluna
                                if (i + 1 < imgs.Count)
                                {
                                    table.Cell().Element(cell =>
                                        BuildImageCell(cell, imgs[i + 1].Data));
                                }
                                else
                                {
                                    // Preenche célula vazia para manter alinhamento
                                    table.Cell().Element(cell => cell.Padding(5));
                                }
                            }
                        });
                    });
                }
                else
                {
                    col.Item().PaddingTop(8).Text("Sem imagens anexadas.")
                        .FontSize(10)
                        .FontColor(Colors.Grey.Darken1);
                }
            });
        }

        private static string BuildAddress(Report r)
        {
            var parts = new List<string>();
            if (!string.IsNullOrWhiteSpace(r.Address)) parts.Add(r.Address);
            if (!string.IsNullOrWhiteSpace(r.Bairro)) parts.Add(r.Bairro);
            if (!string.IsNullOrWhiteSpace(r.City)) parts.Add(r.City);
            if (!string.IsNullOrWhiteSpace(r.State)) parts.Add(r.State);
            if (!string.IsNullOrWhiteSpace(r.CEP)) parts.Add("CEP " + r.CEP);

            return parts.Count == 0 ? "Endereço não informado" : string.Join(" · ", parts);
        }

        private static string GetStatusLabel(ReportStatus status)
        {
            return status switch
            {
                ReportStatus.Pending => "Pendente",
                ReportStatus.InProgress => "Em andamento",
                ReportStatus.Resolved => "Resolvido",
                ReportStatus.Dismissed => "Descartado",
                ReportStatus.Inappropriate => "Inapropriado",
                ReportStatus.Diactivated => "Desativado",
                _ => status.ToString()
            };
        }

        private static void BuildImageCell(IContainer container, byte[] imageBytes)
        {
            if (imageBytes == null || imageBytes.Length == 0)
            {
                container
                    .Padding(4)
                    .Border(0.5f)
                    .BorderColor(Colors.Grey.Lighten2)
                    .AlignCenter()
                    .AlignMiddle()
                    .Text("Imagem não disponível")
                    .FontSize(9)
                    .FontColor(Colors.Grey.Darken1);

                return;
            }

            container
                .Padding(4)
                .Border(0.5f)
                .BorderColor(Colors.Grey.Lighten2)
                .AspectRatio(4 / 3f)
                .AlignCenter()
                .AlignMiddle()
                .Image(imageBytes)
                    .FitArea()
                    .WithCompressionQuality(ImageCompressionQuality.Medium);
        }
    }
}
