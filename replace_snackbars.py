import os, glob, re

dart_files = glob.glob('c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/**/*.dart', recursive=True)

# Regex to match showSnackBar
pattern = re.compile(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const\s+)?SnackBar\(\s*content:\s*Text\((.*?)\)\s*(?:,[^)]*)?\)\s*,?\s*\);', re.DOTALL)

for fpath in dart_files:
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'showSnackBar' in content:
        def replacer(match):
            text_content = match.group(1)
            # determine method
            if any(x in text_content.lower() for x in ['yetersiz', 'hata', 'başarısız', 'iptal']):
                method = 'showError'
            else:
                method = 'showSuccess'
            return f'NotificationService.{method}(context, {text_content});'
            
        new_content = pattern.sub(replacer, content)
        if new_content != content:
            print(f'Replaced in {os.path.basename(fpath)}')
            # Actually apply the change
            if 'notification_service.dart' not in new_content:
                new_content = "import 'package:galeriden/core/utils/notification_service.dart';\n" + new_content
            with open(fpath, 'w', encoding='utf-8') as f:
                f.write(new_content)
