namespace _14___Small_web_server
{
    using System;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;
    using System.Threading.Tasks;

    public class StartUp
    {
        static void Main(string[] args)
        {
            int port = 5666;
            IPAddress ipAddress = IPAddress.Parse("127.0.0.1");
            TcpListener tcpListener = new TcpListener(ipAddress, port);
            tcpListener.Start();

            Task.Run(async() =>
            {
                await Connect(tcpListener);
            })
            .GetAwaiter()
            .GetResult();
        }
        public static async Task Connect (TcpListener tcpListener)
        {
            while (true)
            {
                using (TcpClient client = await tcpListener.AcceptTcpClientAsync())
                {
                    byte[] buffer = new byte[1024];

                    await client.GetStream().ReadAsync(buffer, 0, buffer.Length);
                    string clientMessage = Encoding.UTF8.GetString(buffer);
                    Console.WriteLine(clientMessage);
                    // we can use "\n" also for new line but this option which i wrote is better
                    string responseMessage = $"HTTP/1.1 200 OK{Environment.NewLine}Content-Type:text/plain{Environment.NewLine}{Environment.NewLine}Hello from Petko Petkov server";
                    byte[] responseInBytes = Encoding.UTF8.GetBytes(responseMessage);
                    await client.GetStream().WriteAsync(responseInBytes, 0, responseInBytes.Length);
                }
            }
        }
    }
}
