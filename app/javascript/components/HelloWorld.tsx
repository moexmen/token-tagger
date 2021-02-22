import React from "react"

interface Props {
  greeting: string;
}

export default class HelloWorld extends React.Component<Props> {
  render () {
    return (
      <>
        Greeting: {this.props.greeting}
      </>
    );
  }
}

