# OIC3 Promotion via Oracle GitHub Integration

## Purpose
Promote Oracle Integration 3 projects from source to target using:
- Oracle Integration GitHub repository integration
- GitHub Actions orchestration
- Oracle Developer APIs

## Files
- scripts/get_token.sh
- scripts/export_project_to_github.sh
- scripts/list_git_projects.sh
- scripts/import_project_from_github.sh
- .github/workflows/promote-project-via-repo.yml

## Required GitHub secrets
- SRC_OIC_BASE_URL
- SRC_OIC_INSTANCE
- SRC_TOKEN_URL
- SRC_CLIENT_ID
- SRC_CLIENT_SECRET
- SRC_SCOPE
- TGT_OIC_BASE_URL
- TGT_OIC_INSTANCE
- TGT_TOKEN_URL
- TGT_CLIENT_ID
- TGT_CLIENT_SECRET
- TGT_SCOPE

## Oracle prerequisites
1. Configure GitHub repository access in source Oracle Integration instance
2. Configure GitHub repository access in target Oracle Integration instance
3. Ensure both instances point to the intended repo/branch
4. Ensure OAuth confidential apps are created for source and target
5. Ensure the OAuth clients have the required OIC roles

## Run
Open GitHub Actions and run:
- Promote OIC3 project via Oracle GitHub integration

Inputs:
- project_id
- project_label (optional)

## Notes
- This flow works for Oracle Integration projects/project deployments backed by GitHub repository integration.
- If the target already contains conflicting project state, import behavior depends on Oracle-side project/repository state.
