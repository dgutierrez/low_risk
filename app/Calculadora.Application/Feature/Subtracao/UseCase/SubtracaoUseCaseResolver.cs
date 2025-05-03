using Calculadora.Application.Feature.Subtracao.Interfaces;
using Microsoft.AspNetCore.Http;

namespace Calculadora.Application.Feature.Subtracao.UseCase
{
    public class SubtracaoUseCaseResolver : ISubtracaoUseCaseResolver
    {
        private readonly ISubtracaoUseCase _real;
        private readonly ISubtracaoUseCase _mock;
        public SubtracaoUseCaseResolver(SubtracaoUseCase real, SubtracaoUseCaseMock mock)
        {
            _real = real;
            _mock = mock;
        }

        public ISubtracaoUseCase Resolve(HttpContext context)
        {
            var isSimulation = context.Request.Headers.TryGetValue("x-simulation", out var value) &&
                               value.ToString().Equals("true", StringComparison.OrdinalIgnoreCase);

            return isSimulation ? _mock : _real;
        }
    }
}
