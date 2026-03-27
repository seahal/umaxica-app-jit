# Feature Notes

## Customer / Identity

- `customer` を `Identity` 契約にどこまで含めるかは、まだ検討中。
- 現時点では `user` / `staff` と同様に `status_id` と `withdrawable` 系の考え方を共有できる。
- ただし、`customer`
  を auth の同格主体として扱うのか、問い合わせ専用の準主体として扱うのかは未確定。
- ここが固まるまで、`customer` の auth 連携は最小限に留める。
