import {shallow} from 'enzyme'
import * as React from 'react'
import CameraControlContainer, {Props} from 'CAMERA/container/CameraGestureContainer'
import { Point } from 'TYPES';

const setup = () => {
  const props: Props = {
    onLongPress: jest.fn(),
    onPress: jest.fn(),
    onPan: jest.fn(),
    onTouchEnd: jest.fn()
  }
  return shallow(<CameraControlContainer {...props}/>)
}

describe("CameraControlContainer Render", ()=>{
  test("render correctly with default props", () => {
    let wrapper = setup()
    expect(wrapper).toMatchSnapshot()
  })
})

describe("CameraControlContainer Callback", ()=>{
  test("onLongPress should be call when LongPress TouchAbleView", () => {
    let wrapper = setup()
    const pressPoint = {localX: 0, localY: 0}
    wrapper.find({testID:"TouchAbleView"}).simulate("longPress",{nativeEvent: pressPoint})
    expect((wrapper.instance().props as Props).onLongPress).toBeCalledWith(pressPoint)
  })

  test("onPress should be call when press TouchAbleView", () => {
    let wrapper = setup()
    const pressPoint = {localX: 0, localY: 0}
    wrapper.find({testID:"TouchAbleView"}).simulate("press",{nativeEvent: pressPoint})
    expect((wrapper.instance().props as Props).onPress).toBeCalledWith(pressPoint)
  })

  test("onTouchEnd should be call when simulate touchEnd",() =>{
    let wrapper = setup()
    const pressPoint = {locationX: 0, locationY: 0}
    const startPoint = {x: 5, y: 5}
    let instance = wrapper.instance() as CameraControlContainer
    instance.touchStartPoint = {x: 5, y: 5}
    wrapper.find({testID:"GestureView"}).simulate("touchEnd",{nativeEvent: pressPoint})
    expect((wrapper.instance().props as Props).onTouchEnd).toBeCalledWith(startPoint, {x: pressPoint.locationX, y:pressPoint.locationY})
  })

  describe("onPan should be call correctly", () => {
    let wrapper = setup()
    const startPoint = {pageX: 0, pageY: 0, locationY: 0, locationX: 0}
    const targets: {
      input:{pageX: number, pageY: number, locationY: number, locationX: number},
      expect?:{
        startPoint: Point,
        currentPoint: Point,
        delta: Point
      }
    }[] = [
      {
        input: {pageX: 0, pageY: 0, locationY: 0, locationX: 0},
        expect: undefined,
      },
      // 当滑动距离没有超出误差时，不做回调
      {
        input: {pageX: 2, pageY: 1, locationY: 2, locationX: 1},
        expect: undefined,
      },
       // 当滑动距离没有超出误差时，不做回调
      {
        input: {pageX: -1, pageY: -2, locationY: -2, locationX: -1},
        expect: undefined,
      },
      {
        input: {pageX: 0, pageY: 5, locationY: 5, locationX: 0},
        expect: {
          startPoint: {x: startPoint.locationX, y: startPoint.locationY},
          currentPoint: {x: 0, y: 5},
          delta: {x: 0 - -1, y: 5 - -2}
        },
      },
      {
        input: {pageX: 80, pageY: 50, locationY: 50, locationX: 80},
        expect: {
          startPoint: {x: startPoint.locationX, y: startPoint.locationY},
          currentPoint: {x: 80, y: 50},
          delta: {x: 80 - 0, y: 50 - 5}
        },
      },
      {
        input: {pageX: 0, pageY: 0, locationY: 0, locationX: 0},
        expect: {
          startPoint: {x: startPoint.locationX, y: startPoint.locationY},
          currentPoint: {x: 0, y: 0},
          delta: {x: 0 - 80, y: 0 - 50}
        },
      },
      {
        input: {pageX: -50, pageY: -80, locationY: -80, locationX: -50},
        expect: {
          startPoint: {x: startPoint.locationX, y: startPoint.locationY},
          currentPoint: {x: -50, y: -80},
          delta: {x: -50 - 0, y: -80 -0}
        },
      },
    ]
    wrapper.find({testID:"GestureView"}).simulate("touchStart",{nativeEvent: startPoint})
    targets.forEach((testCase)=>{
      test(`when move to x: ${testCase.input.locationX} y: ${testCase.input.locationY}`, ()=>{
        wrapper.find({testID:"GestureView"}).simulate("touchMove",{nativeEvent: testCase.input})
        if(testCase.expect) {
          let {startPoint, currentPoint, delta} = testCase.expect
          expect((wrapper.instance().props as Props).onPan).toBeCalledWith(startPoint,currentPoint,delta)
        } else {
          expect((wrapper.instance().props as Props).onPan).toHaveBeenCalledTimes(0)
        }
      })
    })
  })

})