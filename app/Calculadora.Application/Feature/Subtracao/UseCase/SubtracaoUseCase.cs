using Calculadora.Application.AppModels;
using Calculadora.Application.Feature.Subtracao.Interfaces;

namespace Calculadora.Application.Feature.Subtracao.UseCase
{
    public class SubtracaoUseCase : ISubtracaoUseCase
    {
        const bool isSimulation = false;
        public async Task<GenericResponse> Subtrair(double a, double b)
        {
            return new GenericResponse
            {
                DataObject = new
                {
                    equacao = String.Format("{0} - {1}", a, b),
                    resultado = a - b
                },
                isSimulation = isSimulation
            };
        }
    }
}
