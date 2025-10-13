using AutoMapper;
using TerraON.Application.UseCases.Reports.Create.DTOs;
using TerraON.Application.UseCases.Users.Register.DTOs;
using TerraON.Domain.Entities;

namespace TerraON.Application.Services.AutoMapper
{
    public class AutoMapping : Profile
    {
        public AutoMapping()
        {
            RequestToDomain();
            DomainToResponse();
        }

        private void RequestToDomain()
        {
            CreateMap<RequestCreateUserJson, User>()
                .ForMember(d => d.PasswordHash, o => o.Ignore())
                .ForMember(d => d.Email, o => o.MapFrom(s => s.Email.Trim()))
                .AfterMap((s, d) =>
                {
                    d.NormalizedEmail = d.Email?.ToUpperInvariant();
                });

            CreateMap<RequestCreateReportJson, Report>()
                .ForMember(d => d.Author, o => o.Ignore())
                .ForMember(d => d.Images, o => o.Ignore())
                .ForMember(d => d.Comments, o => o.Ignore())
                .ForMember(d => d.Likes, o => o.Ignore());
        }

        private void DomainToResponse()
        {
            CreateMap<User, ResponseCreatedUserJson>()
                .ForMember(d => d.Name, o => o.MapFrom(s => s.Name))
                .ForMember(d => d.Email, o => o.MapFrom(s => s.Email));
        }
    }
}
