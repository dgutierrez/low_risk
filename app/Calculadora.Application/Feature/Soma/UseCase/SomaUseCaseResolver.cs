using Calculadora.Application.Feature.Soma.Interfaces;
using Microsoft.AspNetCore.Http;

namespace Calculadora.Application.Feature.Soma.UseCase
{
    public class SomaUseCaseResolver : ISomaUseCaseResolver
    {
        private readonly ISomaUseCase _real;
        private readonly ISomaUseCase _mock;

        public SomaUseCaseResolver(
            SomaUseCase real,
            SomaUseCaseMock mock)
        {
            _real = real;
            _mock = mock;
        }

        public ISomaUseCase Resolve(HttpContext context)
        {
            var isSimulation = context.Request.Headers.TryGetValue("x-simulation", out var value) &&
                               value.ToString().Equals("true", StringComparison.OrdinalIgnoreCase);

            return isSimulation ? _mock : _real;
        }
    }
}
