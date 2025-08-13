using Microsoft.AspNetCore.Mvc;
using TerraON.API.Filters;

namespace TerraON.API.Attributes
{
    public class AuthenticatedUserAttribute : TypeFilterAttribute
    {
        public AuthenticatedUserAttribute() : base(typeof(AuthenticatedUserFilter))
        {
        }
    }
}
