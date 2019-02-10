namespace _09___Aync_await_download
{
    using System;
    using System.Net;
    using System.Threading.Tasks;

    public class StartUp
    {
        static void Main(string[] args)
        {
            // whereever we use async and await we does not block anything !!! The main thread is working till we download the file!!!
            // 
            Task.Run(async() => 
            {
                await DownloadFileAsync();
            })
            .GetAwaiter()
            .GetResult();
            // the file is downloaded in bid/debug/netcoreapp2.1/index.html
        }
        public static async Task DownloadFileAsync()
        {
            WebClient wc = new WebClient();
            Console.WriteLine("Downloading");
            await wc.DownloadFileTaskAsync("https://stackoverflow.com/questions/19197376/check-if-task-is-already-running-before-starting-new","index.html");
            Console.WriteLine("Task finished");
        }
    }
}
