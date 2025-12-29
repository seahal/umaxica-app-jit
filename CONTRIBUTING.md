I admire the passion of those who strive to create codes. This product would not have been possible without their encouragement.

## Future Architecture Considerations

### TODO: Identity and Session Architecture Refactoring

将来的に導入を検討しているアーキテクチャ:

```
Account (User, Staff)
  └─ Identity (← Context)
      └─ Persona (← Persona)
          └─ Session (org, app)
```

**概念:**
- **Account**: ユーザーまたはスタッフのベースアカウント
- **Identity**: コンテキストに依存した識別情報
- **Persona**: ペルソナベースの表現
- **Token**: org（組織）とapp（アプリケーション）のセッション管理

**注意**:
現在はリファクタリング中のため、この設計は考慮しないでください。
将来的なアーキテクチャ変更のメモとして残しています。
