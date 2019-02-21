using System;
using System.Collections.Generic;

namespace DbFirstDemoSqlServer.Data.Models
{
    public class Address
    {
        public Address()
        {

        }
        public int AddressId { get; set; }
        public string AddressText { get; set; }
        public int? TownId { get; set; }

        public virtual Town Town { get; set; }
        public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
    }
}
