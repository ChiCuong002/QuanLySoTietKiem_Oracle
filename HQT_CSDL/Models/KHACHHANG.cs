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
    
    public partial class KHACHHANG
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public KHACHHANG()
        {
            this.SOTIETKIEMs = new HashSet<SOTIETKIEM>();
        }
    
        public string MAKH { get; set; }
        public string HOTEN { get; set; }
        public string GIOITINH { get; set; }
        public Nullable<System.DateTime> NGAYSINH { get; set; }
        public string CCCD { get; set; }
        public string DIACHI { get; set; }
        public string SDT { get; set; }
        public string TINHTRANG { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SOTIETKIEM> SOTIETKIEMs { get; set; }
    }
}