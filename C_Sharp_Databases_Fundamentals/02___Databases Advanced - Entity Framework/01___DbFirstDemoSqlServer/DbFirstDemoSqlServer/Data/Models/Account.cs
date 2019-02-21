using System;
using System.Collections.Generic;

namespace DbFirstDemoSqlServer.Data.Models
{
    public partial class Account
    {
        public string Username { get; set; }
        public string Password { get; set; }
        public string Active { get; set; }
    }
}
