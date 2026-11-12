"""Validate mobile upload operations against a reduced source-derived API schema.

Run with the API's Python environment (graphql-core is already a dependency):
  /path/to/ohtk-api/.venv/bin/python tool/check_attachment_contract.py --api-root /path/to/ohtk-api

This checks source argument nullability, not a deployed tenant schema.
"""
import argparse
import ast
import re
from pathlib import Path

from graphql import build_schema, parse, validate


def required_argument(path, class_name, argument):
    module = ast.parse(path.read_text())
    mutation = next(n for n in module.body if isinstance(n, ast.ClassDef) and n.name == class_name)
    arguments = next(n for n in mutation.body if isinstance(n, ast.ClassDef) and n.name == "Arguments")
    assignment = next(n for n in arguments.body if isinstance(n, ast.Assign)
                      and any(isinstance(t, ast.Name) and t.id == argument for t in n.targets))
    return "!" if any(k.arg == "required" and isinstance(k.value, ast.Constant)
                      and k.value.value is True for k in assignment.value.keywords) else ""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--api-root", required=True, type=Path)
    args = parser.parse_args()
    mobile = Path(__file__).resolve().parents[1]
    declarations = [
        ("reports", "submit_image_mutation.py", "SubmitImage", "report_id", "submitImage", "image", "imageId", "reportId", "ImageResult"),
        ("reports", "submit_upload_file_mutation.py", "SubmitUploadFile", "report_id", "submitUploadFile", "file", "fileId", "reportId", "FileResult"),
        ("observations", "submit_observation_image_mutation.py", "SubmitRecordImage", "record_id", "submitRecordImage", "image", "imageId", "recordId", "ImageResult"),
        ("observations", "submit_observation_upload_file_mutation.py", "SubmitRecordUploadFile", "record_id", "submitRecordUploadFile", "file", "fileId", "recordId", "FileResult"),
    ]
    fields = []
    for app, filename, cls, argument, mutation, upload, identifier, parent, result in declarations:
        required = required_argument(args.api_root / app / "schema/mutations" / filename, cls, argument)
        extra = ", recordType: RecordType!" if mutation == "submitRecordImage" else ""
        fields.append(f"{mutation}({upload}: Upload!, {identifier}: UUID, {parent}: UUID{required}{extra}): {result}")
    schema = build_schema("""
        scalar UUID
        scalar Upload
        enum RecordType { subject monitoring }
        type Query { ping: String }
        type ImageResult { id: UUID file: String thumbnail: String imageUrl: String }
        type FileResult { id: UUID file: String fileType: String fileUrl: String }
        type Mutation { %s }
    """ % "\n".join(fields))
    checked = 0
    for filename in ["image_api.dart", "file_api.dart"]:
        source = (mobile / "lib/services/api" / filename).read_text()
        for operation in re.findall(r"const mutation = r'''(.*?)'''", source, re.S):
            document = parse(operation)
            errors = validate(schema, document)
            assert not errors, [e.message for e in errors]
            print(f"PASS {filename}: {document.definitions[0].name.value}")
            checked += 1
    assert checked == 4, f"Expected four upload operations, found {checked}"
    print("4 upload operations match the source-derived parent argument contracts; deployed schema not inspected.")


if __name__ == "__main__":
    main()
