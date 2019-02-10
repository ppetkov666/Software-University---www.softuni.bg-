namespace _11___Async_await_task
{
    using System;
    using System.Net.Http;
    using System.Net.Http.Headers;
    using System.Threading.Tasks;

    public class StartUp
    {
        static void Main(string[] args)
        {
            Task.Run(async() =>
            {
                await GetHeaders("https://www.softuni.bg");
            }).GetAwaiter().GetResult();
            
        }
        public static async Task GetHeaders(string url)
        {
            using (HttpClient httpClient = new HttpClient())
            {
                // when we make request to http server we will get response
                HttpResponseMessage response = await httpClient.GetAsync(url);

                HttpResponseHeaders headers = response.Headers;
                foreach (var header in headers)
                {
                    Console.Write(header.Key + ":");
                    foreach (string item in header.Value)
                    {
                        Console.WriteLine(item);
                    }
                }

                string content = await response.Content.ReadAsStringAsync();
                Console.WriteLine(content);
            }
        }
    }
}
