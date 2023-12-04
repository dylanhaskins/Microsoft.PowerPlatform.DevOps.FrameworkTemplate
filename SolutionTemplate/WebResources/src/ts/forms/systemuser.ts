import { GetDate } from "../../../../../Common/TypescriptLibraries/DateHelper"; //Sample Import from Common TypeScript Helper Library

let Form: Form.systemuser.Main.User;

const OnLoad = function (executionContext: Xrm.ExecutionContext<any, any>) {
  Form = <Form.systemuser.Main.User>executionContext.getFormContext();
  Form.getAttribute("fullname").setValue("Person - " + GetDate(new Date()));
};

export { OnLoad };
