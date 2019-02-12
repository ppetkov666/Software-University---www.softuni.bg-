namespace Web_server_handmade.Server.Http.Response
{
    using Contracts;
    using Enums;
    using System.Text;

    public abstract class HttpResponse : IHttpResponse
    {
        // this class is done in diffferent way than presentation because the parrent class knows only for
        // the common things of his child classes
        private string statusCodeMessage => this.StatusCode.ToString();

        protected HttpResponse()
        {
            this.Headers = new HttpHeaderCollection();
            this.Cookies = new HttpCookieCollection();
        }
        
        public IHttpHeaderCollection Headers { get; }

        public IHttpCookieCollection Cookies { get; }

        public HttpStatusCode StatusCode { get; protected set; }

        // we must generate response example like this  "HTTP/1.1 200 OK"
        //                                              "Content-type: text/html"
        public override string ToString()
        {
            //in general we add in one stringbuilder the whole response in different lines  in the way it should looks like
            StringBuilder response = new StringBuilder();
            
            int statusCodeNumber = (int)this.StatusCode;
            // example: HTTP/1.1 200 OK
            response.AppendLine($"HTTP/1.1 {statusCodeNumber} {this.statusCodeMessage}");
            // example: "Content-type: text/html"
            response.AppendLine(this.Headers.ToString());
            //response.AppendLine();
            return response.ToString();
        }
    }
}
