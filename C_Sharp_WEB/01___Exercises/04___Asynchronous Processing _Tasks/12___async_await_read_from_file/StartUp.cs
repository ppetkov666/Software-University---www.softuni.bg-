namespace _12___async_await_read_from_file
{
    using System;
    using System.IO;
    using System.Threading.Tasks;
    using System.Text;
    using System.Threading;
    using System.Diagnostics;

    public class StartUp
    {
        static void Main(string[] args)
        {
            Task.Run(async() =>
            {
                string output = await ReadFileAsync("test.txt");
                Console.WriteLine(output);
            })
            .GetAwaiter()
            .GetResult();
            Console.WriteLine("reading from file");
        }
        public static async Task<string> ReadFileAsync(string fileName)
        {
            byte[] result;
            Console.WriteLine("Reading...");
            Thread.Sleep(2000);
            using (FileStream reader = File.Open(fileName, FileMode.Open))
            {
                result = new byte[reader.Length];
                await reader.ReadAsync(result, 0, (int)reader.Length);
                Console.WriteLine("File reading completed");
            }
            return Encoding.UTF8.GetString(result);
            
        }
    }
}
