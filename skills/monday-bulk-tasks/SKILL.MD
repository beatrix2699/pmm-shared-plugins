---
name: monday-bulk-tasks
description: |
  Bulk create and update items + subitems on Monday.com boards with full column value mapping (status, date, people, content types). Use this skill whenever the user wants to:
  - Create multiple tasks or items on a Monday.com board at once
  - Create parent items with subitems (nested tasks) in bulk
  - Update many existing items in batch (status, date, assignee, labels)
  - Plan and preview a task list before pushing to Monday
  - Map a content calendar, sprint plan, campaign, or project structure into Monday
  - Replicate a workflow from a spreadsheet, doc, or conversation into Monday tasks
 
  Trigger on phrases like: "tạo tasks trên Monday", "đẩy lên Monday", "tạo hàng loạt", "bulk create", "tạo content plan trên Monday", "update nhiều task", "tạo sprint items", "tạo campaign tasks", "đưa vào Monday", "tạo items cho board", or any request to populate a Monday board with structured data.
---
 
# Monday Bulk Tasks Skill
 
Skill này giúp tạo và update hàng loạt items + subitems trên Monday.com, với preview trước khi execute.
 
---
 
## Workflow tổng quan
 
```
1. Resolve board & group  →  2. Inspect columns  →  3. Build task plan  →  4. Preview  →  5. Confirm  →  6. Execute in batches
```
 
---
 
## Bước 1 — Resolve Board & Group
 
### 1a. Tìm board
```
monday:search(searchType="BOARD", searchTerm="<tên board>")
```
→ Lấy `board.id` (numeric, bỏ prefix "board-")
 
### 1b. Lấy thông tin board (groups + columns + subitem columns)
```
monday:get_board_info(boardId=<id>)
```
 
Từ response, ghi lại:
- `board.groups[]` → id và title của từng group
- `board.columns[]` → id, title, type, settings.labels[] của parent item columns
- `board.subItemColumns[]` → id, title, type, settings.labels[] của subitem columns
 
> **Quan trọng**: Parent item columns và subitem columns **khác nhau hoàn toàn**. Subitem dùng column id từ `subItemColumns`, không phải `columns`.
 
### 1c. Lấy user context (nếu cần PIC)
```
monday:get_user_context()
```
→ Lấy `user.id` cho PIC mặc định (thường là creator/current user)
 
---
 
## Bước 2 — Map Column Values
 
### Parent item columns (board 🟩 2026 GN Content Calendar — tham khảo)
| Column ID     | Type    | Ghi chú |
|---------------|---------|---------|
| `person`      | people  | `{"personsAndTeams": [{"id": <userId>, "kind": "person"}]}` |
| `status__1`   | status  | `{"label": "Working on it"}` — xem labels trong settings |
| `date__1`     | date    | `{"date": "2026-04-01"}` (YYYY-MM-DD) |
 
### Subitem columns (board 🟩 2026 GN Content Calendar — tham khảo)
| Column ID      | Type    | Ghi chú |
|----------------|---------|---------|
| `person`       | people  | same format |
| `status`       | status  | labels: To-do(5), Doing(0), Reviewed(1), Ready(4), Done(6), Cancelled(2), Need review(3) |
| `date0`        | date    | `{"date": "YYYY-MM-DD"}` |
| `status_1__1`  | status  | Content types: Social content(8), Blog(6), Story/reel(13), Video(2), Email marketing(1), eBook(3), Webinar(12), Others(7) |
 
> **Luôn dùng label text** khi set status: `{"label": "To-do"}` thay vì id, để tránh nhầm lẫn giữa boards.
 
---
 
## Bước 3 — Naming Convention
 
Áp dụng prefix nhất quán cho cả parent và subitem:
```
<PREFIX>|<Tên ngắn gọn>
```
 
Ví dụ từ GreenNode AgentBase:
- Parent: `GN|AI Stack|AgentBase|Apr 2026|Awareness`
- Subitem: `GN|AI Stack|AgentBase|AI Agent vs AI Tool — Điều vendor không nói`
 
**Rules:**
- Prefix dùng chung cho parent và subitem — không thêm type label (Social|, Blog|) vào tên
- Content type được track qua column `status_1__1`, không qua tên task
- Tên task: ngắn, rõ ý, không quá 60 ký tự
 
---
 
## Bước 4 — Preview Trước Khi Execute
 
**Bắt buộc** hiển thị preview dạng widget trước khi tạo bất kỳ item nào. Widget cần thể hiện:
 
```
- Board name + Group name
- Tổng số parent items + subitems
- Breakdown theo content type / status
- Từng parent item: tên, status, date, PIC
- Từng subitem: tên, content type, date — grouped dưới parent
- Nút "Xác nhận & tạo" dùng sendPrompt()
```
 
Người dùng review và có thể yêu cầu chỉnh sửa trước khi confirm.
 
---
 
## Bước 5 — Execute: Thứ Tự Tạo
 
### 5a. Tạo parent items trước
```
monday:create_item(
  boardId=<id>,
  groupId=<group_id>,
  name="<PREFIX>|<tên>",
  columnValues={"person": ..., "status__1": ..., "date__1": ...}
)
```
→ Lưu `item_id` trả về cho mỗi parent — cần để tạo subitems
 
### 5b. Tạo subitems (dùng parentItemId)
```
monday:create_item(
  boardId=<id>,
  parentItemId=<parent_item_id>,
  name="<PREFIX>|<tên subitem>",
  columnValues={"person": ..., "status": ..., "date0": ..., "status_1__1": ...}
)
```
 
> **Lưu ý**: Subitems tự động tạo trên subitem board (board id khác). Không cần chỉ định boardId của subitem board.
 
---
 
## Bước 6 — Batching & Error Handling
 
- Tạo **tuần tự**, không song song — tránh rate limit
- Nếu một item fail, **log lỗi + tiếp tục** với item tiếp theo
- Sau khi xong, báo cáo: tổng tạo thành công / tổng fail
- Nếu timeout (>4 phút không response), **retry một lần** trước khi bỏ qua
 
---
 
## Bước 7 — Update Hàng Loạt (nếu cần)
 
### Tìm items cần update
```
monday:get_board_items_page(
  boardId=<id>,
  includeColumns=true,
  filters=[{"columnId": "status__1", "compareValue": ["Working on it"], "operator": "contains_terms"}]
)
```
 
### Update từng item
```
monday:update_item(
  boardId=<id>,
  itemId=<item_id>,
  columnValues={"status__1": {"label": "Done"}, "date__1": {"date": "2026-06-30"}}
)
```
 
Xem `references/update-patterns.md` để biết các pattern update thường gặp.
 
---
 
## Summary Checklist
 
```
[ ] Tìm board ID bằng search
[ ] get_board_info → lấy group IDs, column IDs, label values
[ ] get_user_context → lấy PIC user ID nếu cần
[ ] Build task list với đúng prefix
[ ] Hiển thị preview widget → chờ confirm
[ ] Tạo parent items → lưu item IDs
[ ] Tạo subitems với parentItemId tương ứng
[ ] Báo cáo kết quả + link board
```
 