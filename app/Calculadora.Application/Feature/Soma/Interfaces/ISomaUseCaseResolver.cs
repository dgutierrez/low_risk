using Microsoft.AspNetCore.Http;

namespace Calculadora.Application.Feature.Soma.Interfaces
{
    public interface ISomaUseCaseResolver
    {
        ISomaUseCase Resolve(HttpContext context);
    }
}
