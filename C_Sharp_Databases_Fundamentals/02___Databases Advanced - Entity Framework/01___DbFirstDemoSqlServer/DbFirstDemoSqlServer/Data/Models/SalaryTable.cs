using System;
using System.Collections.Generic;

namespace DbFirstDemoSqlServer.Data.Models
{
    public class SalaryTable
    {
        public int Id { get; set; }
        public string FullName { get; set; }
        public decimal? Salary { get; set; }
    }
}
