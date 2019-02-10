namespace _10___Async_await_download
{
    using System;
    using System.Net.Http;
    using System.Threading.Tasks;

    public class StartUp
    {
        static void Main(string[] args)
        {
            Task.Run(async() =>
            {
                HttpClient client = new HttpClient();
                string result = await client.GetStringAsync("http://softuni.bg");
                Console.WriteLine(result);
            }).GetAwaiter()
            .GetResult();
        }
    }
}
