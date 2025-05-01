using Calculadora.Application.AppModels;
using Calculadora.Application.Feature.Soma.Interfaces;

namespace Calculadora.Application.Feature.Soma.UseCase
{
    public class SomaUseCaseMock : ISomaUseCase
    {
        const bool isSimulation = true;
        public async Task<GenericResponse> Somar(double a, double b)
        {
            return new GenericResponse
            {
                DataObject = new
                {
                    equacao = "3 + 3",
                    resultado = 6
                },
                isSimulation = isSimulation
            };
        }
    }
}
