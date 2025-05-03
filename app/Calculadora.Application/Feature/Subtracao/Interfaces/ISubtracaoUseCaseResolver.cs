using Microsoft.AspNetCore.Http;

namespace Calculadora.Application.Feature.Subtracao.Interfaces
{
    public interface ISubtracaoUseCaseResolver
    {
        ISubtracaoUseCase Resolve(HttpContext context);
    }
}
