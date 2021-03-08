import React, { useState } from 'react';

import TokenChecker, { Result } from './TokenChecker';

export default () => {
  const [result, setResult ] = useState(null);

  const [isFetching, setIsFetching] = useState(false);

  const getStudentWithToken = (tokenId: string) => {
    if (isFetching) {
      return;
    }

    setIsFetching(true);

    if (tokenId !== '') {
      setResult(null);
      
      fetch('/student?' + new URLSearchParams({token_id: tokenId}), {
        method: 'get',
        headers: {
          'Content-Type': 'application/json',
        },
        }).then(resp => resp.json())
        .then(data => {
          setIsFetching(false);
          
          if (data.student == null) {
            setResult({
              result: Result.NoMatch,
              student: null
            });
          } else {
            setResult({
              result: Result.Found,
              student: data.student
            });
          }
        }).catch(e => {
          setIsFetching(false);
          
          setResult({
            result: Result.Error,
            student: null
          });
        });
    }
  }

  return <TokenChecker isFetching={isFetching} result={result} getStudentWithToken={getStudentWithToken} />;
}
