import os
import subprocess

def find_git_repos(directory):
    git_repos = []
    for root, dirs, files in os.walk(directory):
        if '.git' in dirs:
            git_repos.append(root)
            dirs.remove('.git')  # Don't visit .git directories
    return git_repos

def find_non_git_repos(directory):
    non_git_repos = []
    ignored_dirs = {'.git', '.venv', 'node_modules'}
    for item in os.listdir(directory):
        item_path = os.path.join(directory, item)
        if os.path.isdir(item_path) and item not in ignored_dirs:
            if not os.path.exists(os.path.join(item_path, '.git')):
                sub_git_repos = find_git_repos(item_path)
                if not sub_git_repos:
                    non_git_repos.append(item_path)
    return non_git_repos

def get_branch_names(repo_path):
    try:
        result = subprocess.run(['git', '-C', repo_path, 'branch', '--show-current'], capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None

def get_branch_status(repo_path):
    try:
        result = subprocess.run(['git', '-C', repo_path, 'status', '-sb'], capture_output=True, text=True, check=True)
        status_lines = result.stdout.split('\n')
        status_line = status_lines[0]
        
        if 'ahead' in status_line:
            return 'push'
        elif 'behind' in status_line:
            return 'pull'
        elif '...' not in status_line:
            return 'missing remote'
        else:
            for line in status_lines[1:]:
                if line.startswith('??'):
                    return 'untracked files'
                elif line.startswith(' M') or line.startswith('A '):
                    return 'changes to commit'
            return 'up to date'
    except subprocess.CalledProcessError:
        return 'unknown'

def color_text(text, color):
    colors = {
        'green': '\033[92m',
        'amber': '\033[93m',
        'red': '\033[91m',
        'end': '\033[0m'
    }
    return f"{colors[color]}{text}{colors['end']}"

def main(directory=None):
    if directory is None:
        directory = os.getcwd()
    git_repos = find_git_repos(directory)
    non_git_repos = find_non_git_repos(directory)
    
    all_repos = [(repo, 'git') for repo in git_repos] + [(non_repo, 'non-git') for non_repo in non_git_repos]
    all_repos.sort(key=lambda x: os.path.relpath(x[0], directory))
    
    for repo, repo_type in all_repos:
        relative_repo = os.path.relpath(repo, directory)
        if relative_repo == '.':
            relative_repo = os.path.basename(repo)
        
        if repo_type == 'git':
            branch_name = get_branch_names(repo)
            branch_status = get_branch_status(repo)
            
            if branch_status == 'up to date':
                color = 'green'
            elif branch_status in ['unknown', 'missing remote']:
                color = 'red'
            else:
                color = 'amber'
            
            if branch_name:
                print(color_text(f'Repo: {relative_repo}, Branch: {branch_name}, Status: {branch_status}', color))
            else:
                print(color_text(f'Repo: {relative_repo}, Branch: Unknown, Status: {branch_status}', color))
        else:
            print(f'Directory: {relative_repo} is not a Git repository')

if __name__ == "__main__":
    main()