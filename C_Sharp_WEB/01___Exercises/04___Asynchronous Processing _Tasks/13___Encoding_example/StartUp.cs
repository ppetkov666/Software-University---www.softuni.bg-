namespace _13___Encoding_example
{
    using System;
    using System.Diagnostics;
    using System.Text;

    public class StartUp
    {
        static void Main(string[] args)
        {

            string text = "hello world";
            byte[] bytes = Encoding.UTF8.GetBytes(text);
            foreach (Byte singleByte in bytes)
            {
                Console.WriteLine(singleByte);
            }
            string convertedBackTostring = Encoding.UTF8.GetString(bytes);
            Console.WriteLine(convertedBackTostring);
        }   
    }
}
