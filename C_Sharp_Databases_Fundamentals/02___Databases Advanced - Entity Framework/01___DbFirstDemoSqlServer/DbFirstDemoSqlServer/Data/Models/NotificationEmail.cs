using System;
using System.Collections.Generic;

namespace DbFirstDemoSqlServer.Data.Models
{
    public class NotificationEmail
    {
        public int Id { get; set; }
        public int Recipient { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
    }
}
