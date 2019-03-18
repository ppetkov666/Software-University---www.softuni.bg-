namespace External_Format_Processing_demo.Data.Models
{
    public class ProductWarehouse
    {
        public int ProductId { get; set; }
        public Product Product { get; set; }
        public int WarehouseId { get; set; }
        public Warehouse Warehouse { get; set; }

    }
}
