namespace External_Format_Processing_demo
{
    using External_Format_Processing_demo.Data.Models;
    using System;
    using System.IO;
    using System.Runtime.Serialization.Json;
    using System.Text;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;

    public class StartUp
    {
        public static void Main(string[] args)
        {
            Product product = new Product()
            {
                Name = "Tire",
                Description = "makes the car go forward or backward"
            };

            JObject jsonObj = JObject.FromObject(product);
            Console.WriteLine(jsonObj);

            //-----------------------------------------------------
            // EXAMPLE  
            //-----------------------------------------------------
            //var obj = new
            //{
            //    Name = "petko",
            //    Grade = 6,
            //    Grades = new[]
            //    {
            //        4.5,
            //        5.0,
            //        5.33
            //    },
            //};

            //string outputJson = JsonConvert.SerializeObject(obj, Formatting.Indented);

            //var template = new
            //{
            //    Name = default(string),
            //    Grade = default(string),
            //    Grades = new decimal[]
            //    {

            //    },
            //};
            //var deserialized = JsonConvert.DeserializeAnonymousType(outputJson, template);

            //Console.WriteLine(outputJson);

            //-----------------------------------------------------
            // EXAMPLE  serialize product to file
            //-----------------------------------------------------
            //SerilizeToFile(product);

            //-----------------------------------------------------
            // EXAMPLE deserialize it from file
            //-----------------------------------------------------
            //string jsonFromFile = File.ReadAllText(@"..\..\..\jsonArray.json");
            //Product[] deserializedFromFile = JsonConvert.DeserializeObject<Product[]>(jsonFromFile);

            //-----------------------------------------------------
            // EXAMPLE
            //-----------------------------------------------------
            //string jsonString = SerializeObject<Product>(product);
            //Product parsedProduct = DeserializeObject<Product>(jsonString);

            //-----------------------------------------------------
            // EXAMPLE - we demonstrate both process serialization and DE serialization
            // with using Newtonsoft.Json package 
            //-----------------------------------------------------
            //string jsonString = JsonConvert.SerializeObject(product, Formatting.Indented, new JsonSerializerSettings
            //{
            //    NullValueHandling = NullValueHandling.Ignore,
            //    DefaultValueHandling = DefaultValueHandling.Ignore,
            //});
            //Product parsedProduct = JsonConvert.DeserializeObject<Product>(jsonString);

            //Console.WriteLine(jsonString);
        }

        private static void SerilizeToFile(Product product)
        {
            string json = JsonConvert.SerializeObject(product);
            using (StreamWriter file = File.CreateText(@"C:\Users\predator\Desktop\json\jsonArray.json"))
            {
                JsonSerializer serializer = new JsonSerializer();
                serializer.Serialize(file, product);
            }
        }

        private static T DeserializeObject<T>(string jsonString)
        {
            byte[] jsonBytes = Encoding.UTF8.GetBytes(jsonString);
            using (MemoryStream stream = new MemoryStream(jsonBytes))
            {
                DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(T));
                T obj = (T)serializer.ReadObject(stream);
                return obj;
            }
        }

        private static string SerializeObject<T>(T product)
        {
            // it takes the type of the object
            DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(product.GetType());
            using (MemoryStream stream = new MemoryStream())
            {
                //serializes the object to JSON and write it to the stream
                jsonSerializer.WriteObject(stream, product);
                // and then takes string from bytes
                string result = Encoding.UTF8.GetString(stream.ToArray());
                return result;
            }


        }
    }
}
