using Calculadora.Application.AppModels;
using Calculadora.Application.Feature.Soma.Interfaces;

namespace Calculadora.Application.Feature.Soma.UseCase
{
    public class SomaUseCase : ISomaUseCase
    {
        const bool isSimulation = false;
        public async Task<GenericResponse> Somar(double a, double b)
        {
            return new GenericResponse
            {
                DataObject = a + b,
                isSimulation = isSimulation
            };
        }
    }
}
