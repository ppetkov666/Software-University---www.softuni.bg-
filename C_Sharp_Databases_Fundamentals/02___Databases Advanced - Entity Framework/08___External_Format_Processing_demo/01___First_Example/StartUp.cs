namespace External_Format_Processing_demo
{
    using External_Format_Processing_demo.Data.Models;
    using System;
    using System.IO;
    using System.Runtime.Serialization.Json;
    using System.Text;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Linq;
    using System.Xml.Linq;
    using System.Collections.Generic;
    using System.Linq;

    public class StartUp
    {
        public static void Main(string[] args)
        {


            //-----------------------------------------------------
            // EXAMPLE  - XML 
            //-----------------------------------------------------
            XDocument doc = new XDocument();
            doc.Add(new XElement("books"));
            XElement title = new XElement("title", "c# programming");
            XElement description = new XElement("description", "very nice book");
            XElement book = new XElement("book", title, description);
            doc.Element("books").Add(book);
            title = new XElement("title", "java programming");
            description = new XElement("description", "It is ok!");
            book = new XElement("book", title, description);
            doc.Element("books").Add(book);
            //doc.Element("books")
            //    .Add(new XElement("book", new XElement("title","c# programming"),
            //                              new XElement("description", "Great Book"),
            //         new XElement("book", new XElement("title", "java programming"),
            //                              new XElement("description", "It is ok!"))));


            doc.Save("serializedDocument.xml");
            Console.WriteLine(doc.ToString());

            //-----------------------------------------------------
            // EXAMPLE  - XML - reading from file
            //-----------------------------------------------------

            //string xmlString = File.ReadAllText(@"../../../xmlFile.xml");

            //XDocument xml = XDocument.Parse(xmlString);
            //IEnumerable<XElement> elements = xml.Root.Elements();

            //var searchedCarelement = elements
            //    .Where(e => e.Element("Name").Value == "Car")
            //    .Select(e => new
            //    {
            //        name = e.Element("Name")?.Value,
            //        description = e.Element("Description")?.Value,
            //    }).ToArray();

            //foreach (var item in searchedCarelement)
            //{
            //    Console.WriteLine(item.name +"-----" + item.description);
            //}

            //foreach (XElement item in elements)
            //{
            //    // i am showing the both options if value is null with ternary operation , and null coalescing operator
            //    string description = item.Element("Description") == null ? "there is no such a property" : item.Element("Description").Value;
            //    string name = item.Element("Name") == null ? "there is no such a property" : item.Element("Name").Value;

            //    string name1 = item.Element("Name")?.Value;
            //    string description1 = item.Element("Description")?.Value;

            //    string name2 = item.Element("Name")?.Value ?? "no such a property using null coalesce operator";
            //    string description2 = item.Element("Description")?.Value ?? "no such a property using null coalesce operator";

            //    Console.WriteLine(name +"   " +  description);
            //    Console.WriteLine(name1 + "   " + description1);
            //    Console.WriteLine(name2 + "   " + description2);


            //}


            //-----------------------------------------------------
            // EXAMPLE  - JSON
            //-----------------------------------------------------

            //Product product = new Product()
            //{
            //    Name = "Tire",
            //    Description = "makes the car go forward or backward"
            //};

            //JObject jsonObj = JObject.FromObject(product);
            //Console.WriteLine(jsonObj);

            //-----------------------------------------------------
            // EXAMPLE  - JSON
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
            //Console.WriteLine(deserialized.Name);
            //Console.WriteLine(deserialized.Grade);
            //Console.WriteLine(string.Join(" ",deserialized.Grades));


            //-----------------------------------------------------
            // EXAMPLE  serialize product to file - JSON
            //-----------------------------------------------------
            //SerilizeToFile(product);

            //-----------------------------------------------------
            // EXAMPLE deserialize it from file - JSON
            //-----------------------------------------------------
            //string jsonFromFile = File.ReadAllText(@"..\..\..\jsonArray.json");
            //Product[] deserializedFromFile = JsonConvert.DeserializeObject<Product[]>(jsonFromFile);

            //-----------------------------------------------------
            // EXAMPLE - JSON
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
