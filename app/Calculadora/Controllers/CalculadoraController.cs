using Calculadora.Application.Feature.Soma.Interfaces;
using Calculadora.Application.Feature.Subtracao.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Calculadora.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class CalculadoraController : ControllerBase
    {
        private readonly ISomaUseCaseResolver _resolver;
        private readonly ISubtracaoUseCaseResolver _resolverSubtracao;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CalculadoraController(ISomaUseCaseResolver resolver, ISubtracaoUseCaseResolver subResolver, IHttpContextAccessor httpContextAccessor)
        {
            _resolver = resolver;
            _httpContextAccessor = httpContextAccessor;
            _resolverSubtracao = subResolver;
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

        [HttpGet("subtrair")]
        public async Task<IActionResult> Subtrair(double a, double b)
        {
            var useCase = _resolverSubtracao.Resolve(_httpContextAccessor.HttpContext!);
            var resultado = await useCase.Subtrair(a, b);

            var context = _httpContextAccessor.HttpContext!;
            context.Response.Headers.Add("x-simulation", resultado.isSimulation.ToString().ToLower());

            return Ok(resultado);
        }
    }
}
