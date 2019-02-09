namespace Web_Url_tests
{
    using System;
    using System.Net;

    public class StartUp
    {
        public static void Main()
        {
            var url = WebUtility.UrlEncode("https://www.softuni.come/?name=pesho");
            string urlSecond = "https://softuni.bg:447/search?Query=pesho&users=true#go";
            string decodedUrl = WebUtility.UrlDecode(urlSecond);

            Uri parsedUri = new Uri(decodedUrl);
            Console.WriteLine(parsedUri);

            Console.WriteLine(parsedUri.Scheme);
            Console.WriteLine(parsedUri.Host);
            Console.WriteLine(parsedUri.Port);
            Console.WriteLine(parsedUri.AbsolutePath);
            Console.WriteLine(parsedUri.Query);
            Console.WriteLine(parsedUri.Fragment);
        }
    }
}
