Install octokit.

Install [Zach Holman's spark script](https://github.com/holman/spark).

If you're on OS X, use `rake setup` to do this for you. If you're using Chef (and why wouldn't you be?!).

Then, run `./bin/pr-freq.rb`

```
% bin/pr-freq.rb
Version: 12.3.0
Total PRs: 28
Average duration PRs were open: 8.66 days
Average creation-to-release of PRs: 20.11 days
------------------------------------------------------
Version: 12.2.1
Total PRs: 1
Average duration PRs were open: 9.13 hours
Average creation-to-release of PRs: 12.54 hours
------------------------------------------------------
Version: 12.2.0
Total PRs: 19
Average duration PRs were open: 5.4 days
Average creation-to-release of PRs: 9.2 days
------------------------------------------------------
<Other versions snipped>
Total PRs
▁▂▁█▁▁▁▁▂
Average duration PRs were open
▂▂▁▇▄▃▅▁█
Average creation-to-release of PRs
▁▁▁█▂▂▂▁▄
```

# Bugs

See the [issues](https://github.com/jtimberman/chef-pr-freq/issues)

# License and Author

* Author: Joshua Timberman <joshua@chef.io>
* Copyright: Chef Software, Inc. <legal@chef.io>

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
