//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace HQT_CSDL.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class GIAODICH
    {
        public string MAGD { get; set; }
        public Nullable<System.DateTime> NGAYGIAODICH { get; set; }
        public Nullable<decimal> SOTIENGD { get; set; }
        public string LOAIGD { get; set; }
        public string NHANVIENGD { get; set; }
        public string MASTK { get; set; }
    
        public virtual LOAIHINHGD LOAIHINHGD { get; set; }
        public virtual NHANVIEN NHANVIEN { get; set; }
        public virtual SOTIETKIEM SOTIETKIEM { get; set; }
    }
}