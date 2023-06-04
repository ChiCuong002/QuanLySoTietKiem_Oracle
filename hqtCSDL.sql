select * from SOTIETKIEM;
select * from NHANVIEN;
select * from GIAODICH;
--view SOTIETKIEM dang hoat dong
create view v_STK_HD
select * 
from SOTIETKIEM
where TINHTRANG = 'Y'
--function tinh so tien lai co the nhan duoc
create or replace function f_soTienLai(
    v_maSTK SOTIETKIEM.MASTK%TYPE
)
return number
as
    v_sotienlai number;
begin
    select sum(TIENLAI)
    into v_sotienlai
    from BIENDONGSTK
    where MASTK = v_mastk;
    
    return v_sotienlai;
end;


--
create or replace function f_soThangGui (
    v_maSTK SOTIETKIEM.MASTK%TYPE
)
return number
as
    v_SoThangGui number;
begin
    SELECT FLOOR(MONTHS_BETWEEN(sysdate, NGAYMOSO))
    INTO v_SoThangGui
    FROM SOTIETKIEM
    WHERE MASTK = v_maSTK;

    RETURN v_SoThangGui;
exception
    when no_data_found then 
        dbms_output.put_line('Khong co du lieu');
        RETURN NULL;
    when others then 
        dbms_output.put_line('Loi');
        RETURN NULL;
end;
set serveroutput on
begin
    dbms_output.put_line('So ngay gui thuc the la: ' || f_soThangGui('STK108051988'));
end;
--Vi?t hàm tính t?ng s? ti?n giao d?ch mà khách hàng ?ã nh?n ???c t? t?t c? các s? ti?t ki?m mà h? ?ang s? h?u. V?i mã khách hàng là tham s? truy?n vào. (Bùi Chí C??ng)
create or replace function f_TongTienGDKH (
    v_maKH KHACHHANG.MAKH%TYPE
)
return number
as
    v_TongTienLai number;
begin
    select SUM(SOTIENGD)
    into v_TongTienLai
    from KHACHHANG kh, GIAODICH gd, SOTIETKIEM stk
    where kh.MAKH = stk.MAKH
    and stk.MASTK = gd.MASTK;
    
    return v_TongTienLai;
exception
    when no_data_found then 
        dbms_output.put_line('Khong co du lieu');
        RETURN NULL;
    when others then 
        dbms_output.put_line('Loi');
        RETURN NULL;
end;

begin
    dbms_output.put_line('So tien gui tiet kiem la: ' || f_TongTienGDKH('KH001'));
end;
---	S? ?i?n tho?i c?a khách hàng không ???c trùng nhau. (Bùi Chí C??ng)
create or replace trigger tg_SDT_KH
before 
insert or update 
on KHACHHANG
for each row
    declare dem number;
begin
    select count(*)
    into dem
    from KHACHHANG 
    where SDT = :new.SDT;
    
    if (dem >= 1) then
        raise_application_error(-20001,'So dien thoai phai la duy nhat');
    end if;
end;
--	V?i m?i s? ti?t ki?m ngày ??n h?n ph?i l?n h?n ngày m? s? và d?a vào k? h?n. 
create or replace trigger tg_NgayDenHan
before
insert on SOTIETKIEM
for each row
    declare v_ngaydenhan date;
            v_kyhan number;
begin
    select KYHAN
    into v_kyhan
    from LOAITIETKIEM
    where MALOAITK = :new.MALOAITK;
    SELECT ADD_MONTHS(:new.NGAYMOSO, v_kyhan) 
    into v_ngaydenhan
    from DUAL;
    if (:new.NGAYDENHAN < :new.NGAYMOSO or v_ngaydenhan <> :new.NGAYDENHAN) then
       :new.NGAYDENHAN := v_ngaydenhan;
    end if;
end;
---	Nhân viên ph?i có c?n c??c công dân. (Bùi Chí C??ng)
create or replace trigger tg_NV_CCCD
before
insert or update
on NHANVIEN
for each row
begin
    if(:new.CCCD = null) then
        raise_application_error(-20001,'Nhan vien phai co can cuoc cong dan');
    end if;
end;
--3.Vi?t procedure l?y ra danh sách s? ti?t ki?m có s? ti?n g?i trong kho?ng X và Y. V?i X và Y là tham s? truy?n vào. (Bùi Chí C??ng)
create or replace procedure sp_DS_STK_XY(
    v_numberX number,
    v_numberY number
)
as
    cursor c_stk is
    select *
    from SOTIETKIEM
    where SOTIENGUI between v_numberX and v_numberY
    order by MASTK;
begin
    for r in c_stk loop
        dbms_output.put_line('MA SO TIET KIEM: ' || r.MASTK || ', SO TIEN GUI LA ' || r.SOTIENGUI);
    end loop;
end;
set serveroutput on
exec sp_DS_STK_XY(5000000, 20000000)
--procedure th?c hi?n tính lãi su?t cho các s? ti?t ki?m ?ang ho?t ??ng
select * from SOTIETKIEM
CREATE SEQUENCE seq_id_biendongSTK
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
create or replace procedure sp_TinhLai
as
    v_tienlai number;
    v_soThang NUMBER;
    --cursor
    cursor c_stk is
    select stk.MASTK, SOTIENGUI, ltk.KYHAN, ltk.LAISUAT, stk.NGAYMOSO
    from SOTIETKIEM stk, LOAITIETKIEM ltk
    where TINHTRANG ='Y' 
    and TRUNC(EXTRACT(DAY FROM NGAYMOSO)) = TRUNC(EXTRACT(DAY FROM sysdate))
    and stk.MALOAITK = ltk.MALOAITK;
begin
    commit;
    set transaction isolation level read committed;
    for r in c_stk loop
        v_tienlai := ROUND(r.SOTIENGUI * r.LAISUAT / 12, 2);
        v_soThang := FLOOR(MONTHS_BETWEEN(sysdate, r.NGAYMOSO));
        if v_soThang <= r.KYHAN then
        --insert BIENDONGSTK
            insert into BIENDONGSTK values (seq_id_biendongSTK.nextval,r.MASTK,v_sothang,sysdate,r.SOTIENGUI,r.LAISUAT,v_tienlai);
            commit;
        end if;
    end loop;
end;
set serveroutput on
exec  sp_TinhLai()
--Vi?t procedure th?c hi?n ?óng s? ti?t ki?m. (Bùi Chí C??ng)
create or replace procedure sp_TatToanSTK(
    v_mastk SOTIETKIEM.MASTK%TYPE,
    v_manv NHANVIEN.MANV%TYPE,
    v_kq out number,
    v_sotien out number
)
as 
    v_maGD GIAODICH.MAGD%TYPE;
    v_count number;
    no_data exception;
    v_ngaydenhan date;
    v_sotiennhan number;
    v_sotiengoc number;
begin
    commit;
    set transaction isolation level read committed; 
     DBMS_LOCK.sleep(15);
    select count(*), NGAYDENHAN, SOTIENGUI
    into v_count, v_ngaydenhan, v_sotiengoc
    from SOTIETKIEM
    where MASTK = v_mastk
    and TINHTRANG = 'Y'
    group by NGAYDENHAN, SOTIENGUI;
    dbms_output.put_line('count: ' || v_count || ' so tien goc: ' || v_sotiengoc || ' ngay den han la: ' || v_ngaydenhan );
    if v_count = 1 and TRUNC(sysdate) >= TRUNC(v_ngaydenhan) then
        --tong tien goc va lai
        v_sotiennhan := v_sotiengoc + f_soTienLai(v_mastk);
        dbms_output.put_line('So tien goc: ' || v_sotiengoc || ' so tien lai: ' || f_soTienLai(v_mastk) || ' so tien nhan duoc la: ' || v_sotiennhan );
        select 'GD' || LPAD(COALESCE(MAX(TO_NUMBER(SUBSTR(MAGD, 3))), 0) + 1, 2, '0')
        into v_maGD
        from GIAODICH;
        insert into GIAODICH values (v_maGD, sysdate, v_sotiennhan, 'LGD05', v_manv, v_mastk);

        update SOTIETKIEM
        set TINHTRANG = 'N', SOTIENGUI = 0
        where MASTK = v_mastk;
        
        v_kq := 1;
        v_sotien := v_sotiennhan;
    elsif v_count = 1 and TRUNC(sysdate) < TRUNC(v_ngaydenhan)  then
        --tong tien goc va lai
        v_sotiennhan := v_sotiengoc + v_sotiengoc * (0.5 / 100 / 12) * f_soThangGui(v_mastk);
        dbms_output.put_line('So tien nhan duoc: ' || v_sotiennhan);
        select 'GD' || LPAD(COALESCE(MAX(TO_NUMBER(SUBSTR(MAGD, 3))), 0) + 1, 2, '0')
        into v_maGD
        from GIAODICH;
        insert into GIAODICH values (v_maGD, sysdate, v_sotiennhan, 'LGD04', v_manv, v_mastk);

        update SOTIETKIEM
        set TINHTRANG = 'N', SOTIENGUI = 0
        where MASTK = v_mastk;
        
        v_kq := 2;
        v_sotien := v_sotiennhan;
    else
        raise no_data;
    end if;
exception
    when no_data_found then
        v_kq := 4;
        v_sotien := 0;
    when no_data then 
        v_kq := 3;
        v_sotien := 0;
    dbms_output.put_line('Khong co du lieu');
end;


select * from SOTIETKIEM where MASTK = 'STK271107097';
select * from GIAODICH where MASTK = 'STK271107097';
declare 
    v_kq number;
    v_sotien number;
begin
    SP_TATTOANSTK('STK108051988','NV01',v_kq, v_sotien);
    dbms_output.put_line('kq: ' || v_kq || ' so tien: ' || v_sotien);
end;
--Vi?t procedure thêm m?i nhân viên. (Bùi Chí C??ng)
CREATE SEQUENCE useraccount_seq
START WITH 26
INCREMENT BY 1
NOCACHE
NOCYCLE;

select * from NHANVIEN;
select * from USERACCOUNT;
select * from QUYEN;
create or replace procedure sp_ThemNhanVien(
    v_hoten NHANVIEN.HOTEN%TYPE,
    v_gioitinh NHANVIEN.GIOITINH%TYPE,
    v_ngaysinh date,
    v_cccd NHANVIEN.CCCD%TYPE,
    v_DIACHI NHANVIEN.DIACHI%TYPE,
    v_SDT NHANVIEN.SDT%TYPE,
    v_MAQUAY NHANVIEN.MAQUAY%TYPE,
    v_TENDANGNHAP NHANVIEN.TENDANGNHAP%TYPE,
    v_MATKHAU NHANVIEN.MATKHAU%TYPE,
    v_MACV CHUCVU.MACV%TYPE
)
as
    v_check_TDN number;
    check_TDN exception;
    v_manv NHANVIEN.MANV%TYPE;
    check_maquay exception;
    check_MAPQ exception;
    v_check_MQ number;
    v_check_PQ number;
begin
    commit;
    set transaction isolation level read committed;
    DBMS_LOCK.sleep(20);
    --kiem tra khoa ngoai
    select count(*) into v_check_MQ from QUAYGD where MAQUAY = v_MAQUAY;
    select count(*) into v_check_PQ from CHUCVU where MACV = v_MACV;
    select count(*) into v_check_TDN from NHANVIEN where TENDANGNHAP = v_TENDANGNHAP;
    if v_check_MQ = 0 then
        raise check_maquay;
    elsif v_check_PQ = 0 then
        raise check_MAPQ;
    elsif v_check_TDN > 0 then
        raise check_TDN;
    else
    --tao ma nv 
        select 'NV' || LPAD(COALESCE(MAX(TO_NUMBER(SUBSTR(MaNV, 3))), 0) + 1, 3, '0')
        into v_manv
        from NHANVIEN;
    --insert bang nhan vien
        insert into NHANVIEN values (v_manv, v_hoten , v_gioitinh, v_ngaysinh, v_cccd, v_DIACHI, v_SDT,'Y', v_MAQUAY, v_MACV,v_TENDANGNHAP,v_MATKHAU);
    --cap quyen dang nhap cho nhan vien
        execute immediate 'create user ' || v_TENDANGNHAP || ' identified by ' || v_MATKHAU;
        if v_MACV = 'GDV' then
            EXECUTE IMMEDIATE 'GRANT role_GDV TO ' || v_TENDANGNHAP;
        elsif v_MACV = 'QTV' then
            EXECUTE IMMEDIATE 'GRANT role_QTV TO ' || v_TENDANGNHAP;
        elsif v_MACV = 'KT' then
            EXECUTE IMMEDIATE 'GRANT role_KT TO ' || v_TENDANGNHAP;
    --commit
        end if;
        commit;
    end if;
exception
    when check_TDN then dbms_output.put_line('Ten dang nhap da ton tai');
    when check_maquay then dbms_output.put_line('Loi khoa ngoai ma quay giao dich');
    when check_MAPQ then dbms_output.put_line('Loi khoa ngoai ma phan quyen');
end;



select * from NHANVIEN;
select * from USERACCOUNT;
select * from QUAYGD
insert into CHUCVU values ('GDV', 'Giao d?ch viên');
insert into CHUCVU values ('QTV', 'Qu?n tr? viên');
insert into CHUCVU values ('KT', 'K? toán');
begin
    sp_ThemNhanVien('Bui Chi Cuong QTV','Nam',sysdate,'079202018073','C10','0934926110','MQ23','qtv_cuong','123','QTV');
end;
--Vi?t procedure th?c hi?n rút ti?n t? s? ti?t ki?m. (Bùi Chí C??ng)
create or replace procedure sp_RutTIen(
    v_mastk SOTIETKIEM.MASTK%TYPE,
    v_sotien_rut number,
    v_manv NHANVIEN.MANV%TYPE,
    v_errorCode out number
)
as
    v_sotien number;
    check_sotien exception;
    v_countSTK number := 0;
    check_mastk exception;
    v_countNV number := 0;
    check_manv exception;
    v_maGD varchar(10);
begin
    commit;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    DBMS_LOCK.sleep(20);
    select count(*) into v_countSTK from SOTIETKIEM where MASTK = v_mastk;
    select count(*) into v_countNV from NHANVIEN where MANV = v_manv;
    select SOTIENGUI into v_sotien from SOTIETKIEM where MASTK = v_mastk;
    if v_countSTK = 0 then
        raise check_mastk;
    elsif v_countNV = 0  then
        raise check_manv;
    elsif v_sotien < v_sotien_rut then
        raise check_sotien;
    else
        update SOTIETKIEM
        set SOTIENGUI = SOTIENGUI - v_sotien_rut
        where MASTK = v_mastk;
        
        select 'GD' || LPAD(COALESCE(MAX(TO_NUMBER(SUBSTR(MAGD, 3))), 0) + 1, 2, '0')
        into v_maGD
        from GIAODICH;
        insert into GIAODICH values (v_maGD, sysdate, v_sotien_rut, 'LGD01', v_manv, v_mastk);
        
        commit;
        v_errorCode := 0;
    end if;
exception
  when check_sotien then
        v_errorCode := 1;
        dbms_output.put_line('Loi so tien trong so tiet kiem khong du');
    when check_mastk then
        v_errorCode := 2; 
        dbms_output.put_line('Loi khoa ngoai ma so tiet kiem');
    when check_manv then
        v_errorCode := 3;
        dbms_output.put_line('Loi khoa ngoai ma nhan vien');
end;


select * from SOTIETKIEM where MASTK = 'STK271107097';
select * from GIAODICH where MASTK = 'STK271107097';
set serveroutput on
begin
    sp_RutTIen('STK271107097',300000,'NV01');
end;
--dong so tiet kiem tu dong
create or replace trigger tg_TUDONGSTK
after update on SOTIETKIEM 
for each row
begin
    if :new.SOTIENGUI = 0 then
        update SOTIETKIEM
        set TINHTRANG = 'N'
        where MASTK = :new.MASTK;
    end if;
end;
--tao role
create role role_GDV
grant create session to role_GDV
grant select on KHACHHANG to role_GDV;
grant select on SOTIETKIEM to role_GDV;
grant select on GIAODICH to role_GDV;
grant select on LOAITIETKIEM to role_GDV;
grant select on LOAIHINHGD to role_GDV;
grant insert on SOTIETKIEM to role_GDV;
grant update on SOTIETKIEM to role_GDV;
grant insert on GIAODICH to role_GDV;
grant execute on SP_GUITIEN to role_GDV;
grant execute on SP_RUTIEN to role_GDV;
grant execute on SP_TATTOANSTK to role_GDV;
grant execute on THEM_SO_TIET_KIEM to role_GDV;
--role quan tri vien
create role role_QTV;
grant create session to role_QTV;
grant select on KHACHHANG to role_QTV;
grant select on NHANVIEN to role_QTV;
grant select on LOAITIETKIEM to role_QTV;
grant select on PHONGGD to role_QTV;
grant select on QUAYGD to role_QTV;
grant insert on KHACHAHNG to role_QTV;
grant update on KHAHCHANG to role_QTV;
grant insert on NHANVIEN to role_QTV;
grant update on NHANVIEN to role_QTV;
grant update on LOAITIETKIEM to role_QTV;
grant update on LOAITIETKIEM to role_QTV;
grant update on PHONGGD to role_QTV;
grant update on PHONGGD to role_QTV;
grant update on QUAYGD to role_QTV;
grant update on QUAYGD to role_QTV;
GRANT EXECUTE ON SP_DANGNHAP TO role_QTV;
grant execute on SP_THEMNHANVIEN;
grant execute on DELETE_EMPLOYEE;
grant execute on SUATHONGTINNHANVIEN;
grant execute on THEM_KHACH_HANG;
grant execute on UPDATE_CUSTOMER_INFO;
--role ke toan
create role role_KT;
grant create session to role_KT;
grant select on KHACHHANG to role_KT;
grant select on NHANVIEN to role_KT;
grant select on SOTIETKIEM to role_KT;
grant select on LOAITIETKIEM to role_KT;
grant select on GIAODICH to role_KT;
--sp dang nhap
drop procedure sp_DangNhap
CREATE OR REPLACE PROCEDURE SP_DANGNHAP(
    v_TENDANGNHAP IN NVARCHAR2,
    v_MATKHAU IN NVARCHAR2,
    v_KetQua OUT NUMBER
)
AS
BEGIN
    SELECT COUNT(*) INTO v_KetQua
    FROM NHANVIEN
    WHERE TENDANGNHAP = v_TENDANGNHAP AND MATKHAU = v_MATKHAU;
END;


--gui tien tiet kiem
select * from SOTIETKIEM;
select * from GIAODICH;
select * from LOAIHINHGD;
create or replace procedure sp_GUITIEN(
    v_sotiengui number,
    v_manv NHANVIEN.MANV%TYPE,
    v_mastk SOTIETKIEM.MASTK%TYPE
)
as
    v_sotien number;
    check_sotien exception;
    v_countSTK number := 0;
    check_mastk exception;
    v_countNV number := 0;
    check_manv exception;
    v_maGD varchar(10);
begin
    commit;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    DBMS_LOCK.sleep(20);
    select count(*) into v_countSTK from SOTIETKIEM where MASTK = v_mastk;
    select count(*) into v_countNV from NHANVIEN where MANV = v_manv;
     if v_countSTK = 0 then
        raise check_mastk;
    elsif v_countNV = 0  then
        raise check_manv;
    else
        --update SOTIENGUI
        update SOTIETKIEM
        set SOTIENGUI = SOTIENGUI + v_sotiengui
        where MASTK = v_mastk;
        --insert GIAODICH
        select 'GD' || LPAD(COALESCE(MAX(TO_NUMBER(SUBSTR(MAGD, 3))), 0) + 1, 2, '0')
        into v_maGD
        from GIAODICH;
        insert into GIAODICH values (v_maGD, sysdate, v_sotiengui, 'LGD03', v_manv, v_mastk);
        
        commit;
    end if;
exception
    when check_mastk then dbms_output.put_line('Loi khoa ngoai ma so tiet kiem');
    when check_manv then dbms_output.put_line('Loi khoa ngoai ma nhan vien');
end;

begin
    sp_GUITIEN('2000000','NV01','STK108051986');
end;
--
CREATE SEQUENCE YOUR_SEQUENCE_NAME
    START WITH 1
    INCREMENT BY 1;
CREATE OR REPLACE PROCEDURE THEM_SO_TIET_KIEM (     
    p_MaKH KHACHHANG.MaKH%TYPE,
    p_NgayMoSo DATE,
    p_NgayDenHan DATE,
    p_SoTienGui SOTIETKIEM.SoTienGui%TYPE,
    p_MaLoaiTK LOAITIETKIEM.MaLoaiTK%TYPE,
    p_MaNV NHANVIEN.MaNV%TYPE
) AS
    v_CountKH NUMBER;
    v_CountLoaiTK NUMBER;
    v_CountNV NUMBER;
    v_MaSTK SOTIETKIEM.MaSTK%TYPE;
BEGIN
    -- Thi?t l?p c?p ?? cô l?p giao d?ch thành READ COMMITTED
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    dbms_lock.sleep(30);
    -- Check if p_MaKH exists
    SELECT COUNT(*) INTO v_CountKH
    FROM KHACHHANG
    WHERE MaKH = p_MaKH;
    
    IF v_CountKH = 0 THEN
        DBMS_OUTPUT.PUT_LINE('L?i: Mã KH không t?n t?i.');
        RETURN;
    END IF;
    
    -- Check if p_MaLoaiTK exists
    SELECT COUNT(*) INTO v_CountLoaiTK
    FROM LOAITIETKIEM
    WHERE MaLoaiTK = p_MaLoaiTK;
    
    IF v_CountLoaiTK = 0 THEN
        DBMS_OUTPUT.PUT_LINE('L?i: Mã Lo?i TK không t?n t?i.');
        RETURN;
    END IF;
    
    -- Check if p_MaNV exists
    SELECT COUNT(*) INTO v_CountNV
    FROM NHANVIEN
    WHERE MaNV = p_MaNV;
    
    IF v_CountNV = 0 THEN
        DBMS_OUTPUT.PUT_LINE('L?i: Mã NV không t?n t?i.');
        RETURN;
    END IF;

-- Generate automatic value for MaSTK using a sequence
    SELECT 'STK' || LPAD(YOUR_SEQUENCE_NAME.NEXTVAL, 9, '0') INTO v_MaSTK FROM DUAL;
    
    -- Insert new record into SOTIETKIEM
    INSERT INTO SOTIETKIEM (
        MaSTK, MaKH, NgayMoSo, NgayDenHan, SoTienGui, MaLoaiTK, MaNV, TINHTRANG
    ) VALUES (
        v_MaSTK, p_MaKH, TRUNC(p_NgayMoSo), p_NgayDenHan, p_SoTienGui, p_MaLoaiTK, p_MaNV, 'Y'
    );
    
    DBMS_OUTPUT.PUT_LINE('?ã thêm m?i s? ti?t ki?m v?i mã STK ' || v_MaSTK);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('L?i: ' || SQLERRM);
        ROLLBACK;
END;

set serveroutput on
BEGIN
    THEM_SO_TIET_KIEM('KH002', '21-MAY-2023' , sysdate, 5000000, 'LTK10', 'NV031');
END;
select * from SOTIETKIEM
select * from KHACHHANG
update SOTIETKIEM
set MASTK = 'STK000000002'
where MASTK = 'STK2';
commit;

CREATE OR REPLACE PROCEDURE SuaThongTinNhanVien (
    p_MaNV IN CHAR,
    p_HoTen IN NVARCHAR2,
    p_GioiTinh IN NVARCHAR2,
    p_NgaySinh IN DATE,
    p_CCCD IN CHAR,
    p_DiaChi IN NVARCHAR2,
    p_SDT IN CHAR,
    p_TinhTrang IN CHAR,
    p_MaQuay IN CHAR
)
IS
    v_HoTen NVARCHAR2(80);
BEGIN
    -- Truy xu?t thông tin nhân viên tr??c khi c?p nh?t
    SELECT HoTen INTO v_HoTen
    FROM NHANVIEN
    WHERE MaNV = p_MaNV;

    -- In thông tin nhân viên tr??c khi c?p nh?t
    DBMS_OUTPUT.PUT_LINE('Thông tin nhân viên tr??c khi c?p nh?t:');
    DBMS_OUTPUT.PUT_LINE('MaNV: ' || p_MaNV);
    DBMS_OUTPUT.PUT_LINE('HoTen: ' || v_HoTen);
    
    -- C?p nh?t thông tin nhân viên
    UPDATE NHANVIEN
    SET HoTen = p_HoTen,
        GioiTinh = p_GioiTinh,
        NgaySinh = p_NgaySinh,
        CCCD = p_CCCD,
        DiaChi = p_DiaChi,
        SDT = p_SDT,
        TinhTrang = p_TinhTrang,
        MaQuay = p_MaQuay
    WHERE MaNV = p_MaNV;
    
    COMMIT;
    
    -- In thông tin nhân viên sau khi c?p nh?t
    DBMS_OUTPUT.PUT_LINE('Thông tin nhân viên sau khi c?p nh?t:');
    DBMS_OUTPUT.PUT_LINE('MaNV: ' || p_MaNV);
    DBMS_OUTPUT.PUT_LINE('HoTen: ' || p_HoTen);
    DBMS_OUTPUT.PUT_LINE('Thông tin nhân viên ?ã ???c c?p nh?t.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nhân viên không t?n t?i.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('L?i: ' || SQLERRM);
        ROLLBACK;
END;

CREATE OR REPLACE PROCEDURE delete_employee (p_employee_id IN char)
IS
BEGIN
  -- C?p nh?t tình tr?ng c?a nhân viên ?ã b? xóa
  UPDATE NHANVIEN
  SET TinhTrang = 'N'
  WHERE MaNV = p_employee_id;
  
  COMMIT;
END;


CREATE OR REPLACE PROCEDURE update_customer_info (
p_MaKH in char,
p_HoTen in nvarchar2,
p_GioiTinh nvarchar2,
p_NgaySinh in date,
p_CCCD in char,
p_DiaChi nvarchar2,
p_SDT in char,
p_TinhTrang in char
)
IS
BEGIN
    UPDATE KHACHHANG
    SET HoTen = p_HoTen,
    GioiTinh = p_GioiTinh,
    NgaySinh = p_NgaySinh,
    CCCD = p_CCCD,
    DiaChi = p_DiaChi,
    SDT = p_SDT,
    TinhTrang = p_TinhTrang
    where MAKH = p_MAKH;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Thông tin khách hàng ???c c?p nh?t thành công.');
    
    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('L?i c?p nh?t thông tin khách hàng: ' || SQLERRM);
END;


CREATE OR REPLACE PROCEDURE THEM_KHACH_HANG(
    p_MaKH IN KHACHHANG.MaKH%TYPE,
    p_HoTen IN KHACHHANG.HoTen%TYPE,
    p_GioiTinh IN KHACHHANG.GioiTinh%TYPE,
    p_NgaySinh IN KHACHHANG.NgaySinh%TYPE,
    p_CCCD IN KHACHHANG.CCCD%TYPE,
    p_DiaChi IN KHACHHANG.DiaChi%TYPE,
    p_SDT IN KHACHHANG.SDT%TYPE,
    p_TinhTrang IN KHACHHANG.TinhTrang%TYPE
)
IS
    v_makh KHACHHANG.MAKH%TYPE;
BEGIN
    select 'KH' || LPAD(COALESCE(MAX(TO_NUMBER(SUBSTR(MAKH, 3))), 0) + 1, 3, '0')
    into v_makh
    from KHACHHANG;
    INSERT INTO KHACHHANG(MaKH, HoTen, GioiTinh, NgaySinh, CCCD, DiaChi, SDT, TinhTrang)
    VALUES (v_makh, p_HoTen, p_GioiTinh, p_NgaySinh, p_CCCD, p_DiaChi, p_SDT, p_TinhTrang);

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Khách hàng ' || p_HoTen || ' ?ã ???c thêm m?i thành công');
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback transaction n?u có l?i
        ROLLBACK;
        -- In thông báo l?i
        DBMS_OUTPUT.PUT_LINE('L?i: ' || SQLERRM);
END;

delete from KHACHHANG where MAKH = '1'
commit;
CREATE OR REPLACE PROCEDURE XOA_KHACH_HANG(
    p_MaKH KHACHHANG.MAKH%TYPE
) AS
BEGIN
    -- C?p nh?t tình tr?ng khách hàng thành 'N' (Ng?ng ho?t ??ng)
    UPDATE KHACHHANG
    SET TinhTrang = 'N'
    WHERE MaKH = p_MaKH;

    -- In thông báo thành công
    DBMS_OUTPUT.PUT_LINE('Da cap nhat tinh trang khach hang voi ma KH ' || p_MaKH || ' thanh "Ngung hoat dong".');
EXCEPTION
    WHEN OTHERS THEN
        -- In thông báo l?i
        DBMS_OUTPUT.PUT_LINE('Loi: ' || SQLERRM);
END;


CREATE OR REPLACE TRIGGER KIEM_TRA_DO_TUOI_KHACH_HANG
BEFORE INSERT OR UPDATE ON KHACHHANG
FOR EACH ROW
DECLARE
    v_Tuoi NUMBER;
BEGIN
    -- Tính tu?i c?a khách hàng d?a trên ngày sinh
    v_Tuoi := TRUNC(MONTHS_BETWEEN(SYSDATE, :NEW.NgaySinh) / 12);

    -- Ki?m tra n?u tu?i nh? h?n 18
    IF v_Tuoi < 18 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Do tuoi khach hang phai lon hon hoac bang 18.');
    END IF;
END;

select * from KHACHHANG
set serveroutput on
update KHACHHANG
set NGAYSINH = '14-JUN-2019'
where MAKH = 'KH003';

create or replace trigger tg_NgayMoSo
before insert on SOTIETKIEM
for each row
begin
    if (TRUNC(:new.NGAYMOSO) <> TRUNC(sysdate)) then
       :new.NGAYMOSO := sysdate;
    end if;
end;

CREATE OR REPLACE TRIGGER TRG_KIEM_TRA_CANCUOC
BEFORE INSERT OR UPDATE ON KHACHHANG
FOR EACH ROW
DECLARE
    v_Count NUMBER;
BEGIN
    -- Ki?m tra n?u không có c?n c??c công dân
    IF :NEW.CCCD IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Khách hàng ph?i có c?n c??c công dân');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE;
END;
select * from plstk.KHACHHANG
insert into plstk.KHACHHANG values ('KH033','Bùi Chí C??ng','Nam','15-Jun-2023','079202018073','Qu?n 8','0934926110','Y');