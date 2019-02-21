using System;
using System.Collections.Generic;

namespace DbFirstDemoSqlServer.Data.Models
{
    public class Department
    {
        public Department()
        {
            
        }

        public int DepartmentId { get; set; }
        public string Name { get; set; }
        public int ManagerId { get; set; }
        public virtual Employee Manager { get; set; }
        public virtual ICollection<Employee> Employees { get; set; } = new List <Employee>();
    }
}
