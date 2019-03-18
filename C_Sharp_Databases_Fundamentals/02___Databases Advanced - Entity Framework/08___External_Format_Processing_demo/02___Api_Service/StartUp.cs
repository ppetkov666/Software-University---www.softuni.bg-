namespace _02___Api_Service
{
    using System;
    using System.IO;
    using System.Net;
    using System.Runtime.Serialization.Json;
    using System.Text;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;
    public class StartUp
    {
        public static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            string json = string.Empty;
            using (WebClient client = new WebClient())
            {
                json = client.DownloadString("example.com/api");
            }
            //parse it into array of ExampleDto 
            var listOfExamples = JsonConvert.DeserializeObject<ExampleDto[]>(json);
            foreach (var example in listOfExamples)
            {
                Console.WriteLine($"{example.Name}-{example.Age}-{example.Color}-{example.Description}");
            }
        }
    }
}
