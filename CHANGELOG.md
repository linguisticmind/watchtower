# watchtower changelog

<table>
    <tr>
        <th>Version</th>
        <th>Date</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>
            <a href='https://github.com/linguisticmind/watchtower/releases/tag/v0.1.1'>0.1.1</a>
        </td>
        <td>
            -
        </td>
        <td>
            <p>
                Added a <code>(dry run)</code> indicator to some prompts that didn't have it.
            </p>
            <p>
                <code>--config</code> now works with <code>--exec-verbose</code> and <code>--exec-risky</code>.
            </p>
            <p>
                Fixes to the <code>--edit --copy</code> mode:
                <ul>
                    <li>In <code>vim</code> / <code>nvim</code>, contents of the new file would get appended to the contents of the old file when a file matching <code>&lt;new_script_name&gt;</code> already existed. Now fixed.</li>
                    <li>In the prompt "A file with the name <code>&lt;script_name&gt;</code> already exists", <code>&lt;old_script_name&gt;</code> would be displayed instead of <code>&lt;new_script_name&gt;</code>. Now fixed.</li>
                </ul>
            </p>
        </td>
    </tr>
    <tr>
        <td>
            <a href='https://github.com/linguisticmind/watchtower/releases/tag/v0.1.0'>0.1.0</a>
        </td>
        <td>
            2025-11-20
        </td>
        <td>
            <p>
                Initial release.
            </p>
        </td>
    </tr>
</table>
