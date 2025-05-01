using Calculadora.Application.AppModels;

namespace Calculadora.Application.Feature.Soma.Interfaces
{
    public interface ISomaUseCase
    {
        public Task<GenericResponse> Somar(double a, double b);
    }
}
