
# Compatibility Matrix

| Module Version / Kubernetes Version |       1.14.X       |       1.15.X       |       1.16.X       |       1.17.X       |       1.18.X       |       1.19.X       |       1.20.X       |       1.21.X       |       1.22.X       | 1.23.X    |
|-------------------------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|-----------|
| v1.0.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |           |
| v1.0.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |           |
| v1.0.2                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |           |
| v1.1.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |                    |                    |                    |           |
| v1.2.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |                    |                    |                    |           |
| v1.2.1                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |                    |           |
| v1.3.0                              |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |           |
| v1.3.1                              |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |                    |           |
| v1.4.0                              |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |                    |           |
| v1.5.0                              |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |     :warning:      |           |
| v1.6.0                              |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning: |

| Legend             | Description  |
|:------------------:|--------------|
| :white_check_mark: | Compatible   |
| :warning:          | Has issues   |
| :x:                | Incompatible |

## Warnings

- :warning: module version `v1.3.0` along with Kubernetes Version `1.20.x` works as expected,Marked as a warning because it is not officially supported.
- :warning: module version `v1.4.0` along with Kubernetes Version `1.21.x` works as expected,Marked as a warning because it is not officially supported.
- :warning: module version `v1.5.0` along with Kubernetes Version `1.22.x` works as expected,Marked as a warning because it is not officially supported.
- :warning: module version `v1.6.0` along with Kubernetes Version `1.23.x` works as expected,Marked as a warning because it is not officially supported.
- :x: module versions `v1.1.0` and `v1.2.0` do not work on Kubernetes > `1.19.x` due to this [issue](https://github.com/open-policy-agent/gatekeeper/issues/820).
