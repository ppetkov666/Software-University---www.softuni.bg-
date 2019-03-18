using Newtonsoft.Json;

namespace _02___Api_Service
{
    public class ExampleDto
    {
        [JsonProperty("name_initial")]
        public string Name { get; set; }
        public int Age { get; set; }
        public string Color { get; set; }
        public string Description { get; set; }

    }
}