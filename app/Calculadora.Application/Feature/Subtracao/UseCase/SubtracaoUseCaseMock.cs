using Calculadora.Application.AppModels;
using Calculadora.Application.Feature.Subtracao.Interfaces;

namespace Calculadora.Application.Feature.Subtracao.UseCase
{
    public class SubtracaoUseCaseMock : ISubtracaoUseCase
    {
        const bool isSimulation = true;
        public async Task<GenericResponse> Subtrair(double a, double b)
        {
            return new GenericResponse
            {
                DataObject = new
                {
                    equacao = String.Format("{0} - {1}", 8, 3),
                    resultado = 5
                },
                isSimulation = isSimulation
            };
        }
    }
}
