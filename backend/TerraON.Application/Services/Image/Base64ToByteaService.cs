using System;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace TerraON.Application.Services.Image
{
    public static class Base64ToByteaService
    {
        // Regex para capturar "data:image/png;base64,AAAA..."
        private static readonly Regex DataUrlRegex = new(
            @"^\s*data:(?<ct>[-\w.+/]+)\s*;\s*base64\s*,\s*(?<b64>[A-Za-z0-9+/=_\-\s]+)\s*$",
            RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Singleline);

        /// <summary>
        /// Converte um texto Base64 (com ou sem prefixo data-url) em byte[] e retorna metadados.
        /// </summary>
        /// <param name="base64">String Base64 (ex.: "data:image/png;base64,AAA..." ou "AAA...")</param>
        public static (byte[] Data, string ContentType, long SizeBytes) Decode(string base64)
        {
            if (string.IsNullOrWhiteSpace(base64))
                throw new ArgumentException("Conteúdo Base64 vazio.", nameof(base64));

            string? contentType = null;
            string payload = base64.Trim();

            // Detecta se veio no formato data-url
            var match = DataUrlRegex.Match(payload);
            if (match.Success)
            {
                contentType = match.Groups["ct"].Value;
                payload = match.Groups["b64"].Value;
            }

            // Normaliza o Base64:
            payload = Regex.Replace(payload, @"\s+", ""); // remove espaços/quebras de linha
            payload = payload.Replace('-', '+').Replace('_', '/'); // url-safe → padrão
            int mod4 = payload.Length % 4;
            if (mod4 != 0) payload = payload.PadRight(payload.Length + (4 - mod4), '=');

            // Decodifica
            byte[] data;
            try
            {
                data = System.Convert.FromBase64String(payload);
            }
            catch (FormatException ex)
            {
                throw new InvalidOperationException("O conteúdo Base64 fornecido é inválido.", ex);
            }

            if (data.Length == 0)
                throw new InvalidOperationException("O conteúdo decodificado está vazio.");

            // Detecta tipo se não veio no prefixo
            contentType ??= DetectContentType(data) ?? "application/octet-stream";

            return (data, contentType, data.LongLength);
        }

        /// <summary>
        /// Tenta decodificar Base64 de forma segura sem lançar exceções.
        /// </summary>
        public static bool TryDecode(string base64, out byte[] data, out string contentType, out long sizeBytes)
        {
            try
            {
                var result = Decode(base64);
                data = result.Data;
                contentType = result.ContentType;
                sizeBytes = result.SizeBytes;
                return true;
            }
            catch
            {
                data = Array.Empty<byte>();
                contentType = "application/octet-stream";
                sizeBytes = 0;
                return false;
            }
        }

        // Identifica tipos comuns de arquivo por assinatura binária
        private static string? DetectContentType(ReadOnlySpan<byte> bytes)
        {
            if (bytes.Length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return "image/png";
            if (bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) return "image/jpeg";
            if (bytes.Length >= 6 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return "image/gif";
            if (bytes.Length >= 12 && bytes[8] == 'W' && bytes[9] == 'E' && bytes[10] == 'B' && bytes[11] == 'P') return "image/webp";
            if (bytes.Length >= 4 && bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) return "application/pdf";
            return null;
        }

        /// <summary>Gera hash SHA-256 (útil para deduplicar imagens).</summary>
        public static string ComputeSha256Hex(ReadOnlySpan<byte> data)
            => System.Convert.ToHexString(SHA256.HashData(data)).ToLowerInvariant();
    }
}
