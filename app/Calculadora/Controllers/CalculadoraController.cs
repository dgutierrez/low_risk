using Calculadora.Application.Feature.Soma.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Calculadora.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class CalculadoraController : ControllerBase
    {
        private readonly ISomaUseCaseResolver _resolver;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CalculadoraController(ISomaUseCaseResolver resolver, IHttpContextAccessor httpContextAccessor)
        {
            _resolver = resolver;
            _httpContextAccessor = httpContextAccessor;
        }

        [HttpGet("somar")]
        public async Task<IActionResult> Somar(double a, double b)
        {
            var useCase = _resolver.Resolve(_httpContextAccessor.HttpContext!);
            var resultado = await useCase.Somar(a, b);

            var context = _httpContextAccessor.HttpContext!;
            context.Response.Headers.Add("x-simulation", resultado.isSimulation.ToString().ToLower());

            return Ok(resultado);
        }
    }
}
