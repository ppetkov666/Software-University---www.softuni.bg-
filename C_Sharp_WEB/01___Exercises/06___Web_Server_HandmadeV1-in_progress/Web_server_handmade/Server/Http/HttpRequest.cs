namespace Web_server_handmade.Server.Http
{
    using Common;
    using Contracts;
    using Enums;
    using Exceptions;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net;

    public class HttpRequest : IHttpRequest
    {
        private readonly string requestText;

        public HttpRequest(string requestText)
        {
            //make the initial validation 
            CoreValidator.ThrowIfNullOrEmpty(requestText, nameof(requestText));

            this.requestText = requestText;

            this.FormData = new Dictionary<string, string>();
            this.UrlParameters = new Dictionary<string, string>();
            this.Headers = new HttpHeaderCollection();
            this.Cookies = new HttpCookieCollection();

            this.ParseRequest(requestText);
        }

        public IDictionary<string, string> FormData { get; private set; }

        public IDictionary<string, string> UrlParameters { get; private set; }

        public IHttpHeaderCollection Headers { get; private set; }

        public IHttpCookieCollection Cookies { get; private set; }

        public string Path { get; private set; }
        
        public string Url { get; private set; }

        public HttpRequestMethod Method { get; private set; }

        public IHttpSession Session { get; set; }

        public void AddUrlParameter(string key, string value)
        {
            CoreValidator.ThrowIfNullOrEmpty(key, nameof(key));
            CoreValidator.ThrowIfNullOrEmpty(value, nameof(value));
            //if we have 2 params with the same name we just overwrite them
            this.UrlParameters[key] = value;
        }

        private void ParseRequest(string requestText)
        {
            // we split by lines because each line consist different info
            string[] requestLines = requestText.Split(Environment.NewLine);

            // if the request is empthy
            if (!requestLines.Any())
            {
                BadRequestException.ThrowFromInvalidRequest();
            }

            // first line - we parse this example line : GET /users/register HTTP/1.1
            string[] requestLine = requestLines
                .First()
                .Split(new[] { ' ' },StringSplitOptions.RemoveEmptyEntries);

            if (requestLine.Length != 3 || requestLine[2].ToLower() != "http/1.1")
            {
                BadRequestException.ThrowFromInvalidRequest();
            }
            // GET OR POST
            this.Method = this.ParseMethod(requestLine.First());
            this.Url = requestLine[1];
            this.Path = this.ParsePath(this.Url);
            
            this.ParseHeaders(requestLines);
            this.ParseParameters();
            // when we have POST querie and it is the last row: example- username=pesho&password=123456
            this.ParseFormData(requestLines.Last());

            this.ParseCookies();

            this.SetSession();
        }

        private HttpRequestMethod ParseMethod(string method)
        {
            HttpRequestMethod parsedMethod;
            if (!Enum.TryParse(method, true, out parsedMethod))
            {
                BadRequestException.ThrowFromInvalidRequest();
            }

            return parsedMethod;
        }

        //we split by ? and # because we need only the path without querie string and fragment
        private string ParsePath(string url)
            => url.Split(new[] { '?', '#' }, StringSplitOptions.RemoveEmptyEntries)[0];

        private void ParseHeaders(string[] requestLines)
        {
            // this is because we have headers till the first empthy line
            int emptyLineAfterHeadersIndex = Array.IndexOf(requestLines, string.Empty);

            for (int i = 1; i < emptyLineAfterHeadersIndex; i++)
            {
                string currentLine = requestLines[i];
                // the split here is very important because if we split only by ':' it will throw an exception
                string[] headerParts = currentLine.Split(new[] { ": " }, StringSplitOptions.RemoveEmptyEntries);

                if (headerParts.Length != 2)
                {
                    BadRequestException.ThrowFromInvalidRequest();
                }
                 
                string headerKey = headerParts[0];
                string headerValue = headerParts[1].Trim();

                HttpHeader header = new HttpHeader(headerKey, headerValue);

                this.Headers.Add(header);
            }

            if (!this.Headers.ContainsKey(HttpHeader.Host))
            {
                BadRequestException.ThrowFromInvalidRequest();
            }


            // first row is the request ... GET...
            //next couple of rows are headers
            //h1
            //h2
            //h3
            // empthy row
            // request content
        }

        private void ParseCookies()
        {
            if (this.Headers.ContainsKey(HttpHeader.Cookie))
            {
                ICollection<HttpHeader> allCookies = this.Headers.Get(HttpHeader.Cookie);
                
                foreach (HttpHeader cookie in allCookies)
                {
                    if (!cookie.Value.Contains('='))
                    {
                        return;
                    }

                    List<string> cookieParts = cookie
                        .Value
                        .Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)
                        .ToList();
                    
                    if (!cookieParts.Any())
                    {
                        continue;
                    }

                    foreach (string cookiePart in cookieParts)
                    {
                        string[] cookieKeyValuePair = cookiePart
                            .Split(new[] { '=' }, StringSplitOptions.RemoveEmptyEntries);

                        if (cookieKeyValuePair.Length == 2)
                        {
                            string key = cookieKeyValuePair[0].Trim();
                            string value = cookieKeyValuePair[1].Trim();

                            this.Cookies.Add(new HttpCookie(key, value, false));
                        }
                    }
                }
            }
        }

        private void ParseParameters()
        {
            // if does not contain '?' it means we have no querie string to add and return 
            if (!this.Url.Contains('?'))
            {
                return;
            }

            string query = this.Url
                .Split(new[] { '?' }, StringSplitOptions.RemoveEmptyEntries)
                .Last();
            
            this.ParseQuery(query, this.UrlParameters);
        }

        private void ParseFormData(string formDataLine)
        {
            // the method must be post so if we have Get ew just return
            if (this.Method == HttpRequestMethod.Get)
            {
                return;
            }
            // and here we the same logic as parse params
            this.ParseQuery(formDataLine, this.FormData);
        }

        private void ParseQuery(string query, IDictionary<string, string> dict)
        {
            //if does not contain '=' it means we dont have valid key value pair and we return
            if (!query.Contains('='))
            {
                return;
            }
            //example how it should looks like name=gosho&age=33, that is why we split  by '&'
            // to get valid key value pair and then we split by '='
            string[] queryPairs = query.Split(new[] { '&' });

            foreach (string queryPair in queryPairs)
            {
                string[] queryKvp = queryPair.Split(new[] { '=' });

                if (queryKvp.Length != 2)
                {
                    return;
                }

                string queryKey = WebUtility.UrlDecode(queryKvp[0]);
                string queryValue = WebUtility.UrlDecode(queryKvp[1]);

                dict.Add(queryKey, queryValue);
            }
        }
        
        private void SetSession()
        {
            if (this.Cookies.ContainsKey(SessionStore.SessionCookieKey))
            {
                HttpCookie cookie = this.Cookies.Get(SessionStore.SessionCookieKey);
                string sessionId = cookie.Value;

                this.Session = SessionStore.Get(sessionId);
            }
        }

        public override string ToString() => this.requestText;
    }
}
