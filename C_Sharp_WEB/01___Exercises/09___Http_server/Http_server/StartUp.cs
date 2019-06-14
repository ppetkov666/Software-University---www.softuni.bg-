namespace Http_server
{
    using System;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;

    class StartUp
    {
        const string newLine = "\r\n";
        static void Main(string[] args)
        {
            TcpListener tcpListener = new TcpListener(IPAddress.Loopback, 55555);
            tcpListener.Start();

            //programs with infinite loops are called daemons : web servers are daemons, games also 
            while (true)
            {
                // analog to console.ReadLine , and with this method we create socket
                TcpClient client = tcpListener.AcceptTcpClient();
                using (NetworkStream stream = client.GetStream())
                {                    
                    // we create byte array with this size just because our main focus is different and not 
                    // on the buffer 
                    byte[] requestBytes = new byte[100000];
                    // we get bytes num
                    int readedBytes = stream.Read(requestBytes, 0, requestBytes.Length);
                    // and convert it to string(text) with encoding
                    string reqData = Encoding.UTF8.GetString(requestBytes, 0, readedBytes);
                    Console.WriteLine(new string('-', 66));
                    Console.WriteLine(reqData);

                    // writing(response)
                    // once we comply with HTTP protocol rules we already use HTTP protocol as level of abstraction
                    // if i remove the second row from responce we dont have valid response
                    string responseBody = "<h1> Hello Petko !!!</h1>";
                    string responseBodySecondVersion =
                        "<form ><input type='text' name='name' placeholder='Enter your name'/><input type='submit' /></form>";

                    string response = "HTTP/1.0 201 created" + newLine +
                                      "Server: MyCustomServer/6.6" + newLine +
                                      "Content-Type: text/html" + newLine +
                                      $"Content-Length: {responseBodySecondVersion.Length}" + newLine + newLine +
                                      $"{responseBodySecondVersion}";
                    byte[] responseArray = Encoding.UTF8.GetBytes(response);
                    stream.Write(responseArray, 0, responseArray.Length);
                }
            }
        }
    }
}
