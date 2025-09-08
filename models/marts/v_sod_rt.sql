select
    sod.po_number,
    sod.po_item,
    sod.due_date,
    rt.qty,
    '123' as static_value
from {{ source('public', 'sod') }} as sod
left join {{ source('public', 'rt') }} as rt using(po_number, po_item)