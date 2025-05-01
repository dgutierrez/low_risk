using System.Text.Json.Serialization;

namespace Calculadora.Application.AppModels
{
    public class GenericResponse
    {
        [JsonPropertyName("data")]
        public object? DataObject { get; set; }
        [JsonIgnore]
        public bool isSimulation { get; set; }
    }
}
