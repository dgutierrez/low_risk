using Calculadora.Application.AppModels;

namespace Calculadora.Application.Feature.Subtracao.Interfaces
{
    public interface ISubtracaoUseCase
    {
        public Task<GenericResponse> Subtrair(double a, double b);
    }
}
