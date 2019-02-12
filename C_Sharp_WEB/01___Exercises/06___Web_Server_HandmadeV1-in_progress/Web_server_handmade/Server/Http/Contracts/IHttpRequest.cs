namespace Web_server_handmade.Server.Http.Contracts
{
    using Enums;
    using System.Collections.Generic;

    public interface IHttpRequest
    {
        // this is the data that user send through POST request or if not they are empthy
        IDictionary<string, string> FormData { get; }

        // key-value pair
        IHttpHeaderCollection Headers { get; }

        IHttpCookieCollection Cookies { get; }

        string Path { get; }

        // get or post in our case
        HttpRequestMethod Method { get; }

        // this type of url example we keep is this string Url https://www.youtube.com/watch?v=rh260jma1nU&feature=youtu.be#example
        // we have protocOl, host, path , query string and fragment in this url and we have to extract them 
        string Url { get; }

        // id = 5 , title = article , year = 2018 and so on...
        IDictionary<string, string> UrlParameters { get; }

        IHttpSession Session { get; set; }

        void AddUrlParameter(string key, string value);
    }
}
